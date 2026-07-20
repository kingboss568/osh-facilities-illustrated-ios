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
abort "ASC_KEY_FILE does not exist: #{ENV.fetch("ASC_KEY_FILE")}" unless File.exist?(ENV.fetch("ASC_KEY_FILE"))

private_key = OpenSSL::PKey.read(File.read(ENV.fetch("ASC_KEY_FILE")))
token = JWT.encode(
  {
    iss: ENV.fetch("ASC_ISSUER_ID"),
    exp: Time.now.to_i + 20 * 60,
    aud: "appstoreconnect-v1"
  },
  private_key,
  "ES256",
  kid: ENV.fetch("ASC_KEY_ID")
)

uri = URI("https://api.appstoreconnect.apple.com/v1/apps")
uri.query = URI.encode_www_form(
  "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"),
  "fields[apps]" => "name,bundleId,sku,primaryLocale"
)

request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{token}"
response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
body = JSON.parse(response.body)

unless response.is_a?(Net::HTTPSuccess)
  abort "ASC API #{response.code} for #{uri}: #{body["errors"] || body}"
end

apps = body.fetch("data")
abort "No App Store Connect app found for bundle id #{ENV.fetch("APP_IDENTIFIER")}" if apps.empty?

app = apps.first
puts JSON.pretty_generate(
  app: {
    id: app.fetch("id"),
    name: app.dig("attributes", "name"),
    bundleId: app.dig("attributes", "bundleId"),
    sku: app.dig("attributes", "sku"),
    primaryLocale: app.dig("attributes", "primaryLocale")
  }
)

