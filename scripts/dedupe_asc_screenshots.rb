#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "time"
require "uri"
require "jwt"

required = %w[ASC_ISSUER_ID ASC_KEY_ID ASC_KEY_FILE APP_IDENTIFIER]
missing = required.select { |key| ENV[key].to_s.strip.empty? }
abort "Missing required env vars: #{missing.join(', ')}" unless missing.empty?
abort "Set DELETE_DUPLICATE_SCREENSHOTS=1 to remove exact filename duplicates." unless ENV["DELETE_DUPLICATE_SCREENSHOTS"] == "1"

app_version = ENV.fetch("APP_VERSION", "1.1")
private_key = OpenSSL::PKey.read(File.read(ENV.fetch("ASC_KEY_FILE")))
token = JWT.encode(
  { iss: ENV.fetch("ASC_ISSUER_ID"), exp: Time.now.to_i + 20 * 60, aud: "appstoreconnect-v1" },
  private_key,
  "ES256",
  kid: ENV.fetch("ASC_KEY_ID")
)

def request_json(token, method, path, query = {})
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  request = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri)
  request["Authorization"] = "Bearer #{token}"
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  return {} if response.is_a?(Net::HTTPNoContent)

  body = response.body.to_s.empty? ? {} : JSON.parse(response.body)
  abort "ASC API #{response.code} #{method.upcase} #{uri}: #{JSON.pretty_generate(body["errors"] || body)}" unless response.is_a?(Net::HTTPSuccess)
  body
end

apps = request_json(
  token,
  "get",
  "/v1/apps",
  { "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"), "fields[apps]" => "name,bundleId" }
).fetch("data")
abort "App not found." unless apps.length == 1

versions = request_json(
  token,
  "get",
  "/v1/apps/#{apps.first.fetch("id")}/appStoreVersions",
  { "filter[versionString]" => app_version, "limit" => "10" }
).fetch("data")
abort "Expected exactly one App Store version #{app_version}." unless versions.length == 1

localizations = request_json(
  token,
  "get",
  "/v1/appStoreVersions/#{versions.first.fetch("id")}/appStoreVersionLocalizations",
  { "limit" => "50", "fields[appStoreVersionLocalizations]" => "locale" }
).fetch("data")

deleted = []
localizations.each do |localization|
  sets = request_json(
    token,
    "get",
    "/v1/appStoreVersionLocalizations/#{localization.fetch("id")}/appScreenshotSets",
    { "limit" => "50", "fields[appScreenshotSets]" => "screenshotDisplayType" }
  ).fetch("data")

  sets.each do |set|
    screenshots = request_json(
      token,
      "get",
      "/v1/appScreenshotSets/#{set.fetch("id")}/appScreenshots",
      { "limit" => "50" }
    ).fetch("data")

    screenshots.group_by { |row| row.dig("attributes", "fileName") }.each_value do |duplicates|
      duplicates.drop(1).each do |duplicate|
        request_json(token, "delete", "/v1/appScreenshots/#{duplicate.fetch("id")}")
        deleted << {
          locale: localization.dig("attributes", "locale"),
          displayType: set.dig("attributes", "screenshotDisplayType"),
          fileName: duplicate.dig("attributes", "fileName"),
          id: duplicate.fetch("id")
        }
      end
    end
  end
end

puts JSON.pretty_generate(appVersion: app_version, deletedCount: deleted.length, deleted: deleted)
