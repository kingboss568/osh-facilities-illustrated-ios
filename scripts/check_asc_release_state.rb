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

PRODUCT_ID = ENV.fetch("IAP_PRODUCT_ID", "com.taiwanarch.oshfacilities.illustrated.full")
APP_VERSION = ENV.fetch("APP_VERSION", "1.1")

private_key = OpenSSL::PKey.read(File.read(ENV.fetch("ASC_KEY_FILE")))
TOKEN = JWT.encode(
  {
    iss: ENV.fetch("ASC_ISSUER_ID"),
    exp: Time.now.to_i + 20 * 60,
    aud: "appstoreconnect-v1"
  },
  private_key,
  "ES256",
  kid: ENV.fetch("ASC_KEY_ID")
)

def get_json(path, query = {})
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = "Bearer #{TOKEN}"
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  body = response.body.to_s.empty? ? {} : JSON.parse(response.body)
  unless response.is_a?(Net::HTTPSuccess)
    abort "ASC API #{response.code} for #{uri}: #{JSON.pretty_generate(body["errors"] || body)}"
  end
  body
end

apps = get_json(
  "/v1/apps",
  {
    "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"),
    "fields[apps]" => "name,bundleId,sku,primaryLocale"
  }
).fetch("data")
abort "No App Store Connect app found for bundle id #{ENV.fetch("APP_IDENTIFIER")}" if apps.empty?
app = apps.first
app_id = app.fetch("id")

versions = get_json(
  "/v1/apps/#{app_id}/appStoreVersions",
  {
    "filter[versionString]" => APP_VERSION,
    "fields[appStoreVersions]" => "versionString,appStoreState,platform,createdDate",
    "limit" => "10"
  }
).fetch("data")

builds = get_json(
  "/v1/apps/#{app_id}/builds",
  {
    "fields[builds]" => "version,uploadedDate,processingState,expired,usesNonExemptEncryption",
    "limit" => "10"
  }
).fetch("data")

iaps = get_json(
  "/v1/apps/#{app_id}/inAppPurchasesV2",
  {
    "filter[productId]" => PRODUCT_ID,
    "fields[inAppPurchases]" => "name,productId,inAppPurchaseType,state,reviewNote,familySharable,contentHosting"
  }
).fetch("data")

latest_build = builds.max_by { |build| Time.parse(build.dig("attributes", "uploadedDate").to_s) rescue Time.at(0) }
summary = {
  app: {
    id: app_id,
    name: app.dig("attributes", "name"),
    bundleId: app.dig("attributes", "bundleId"),
    sku: app.dig("attributes", "sku"),
    primaryLocale: app.dig("attributes", "primaryLocale")
  },
  requestedVersion: APP_VERSION,
  versions: versions.map do |version|
    {
      id: version.fetch("id"),
      versionString: version.dig("attributes", "versionString"),
      state: version.dig("attributes", "appStoreState"),
      platform: version.dig("attributes", "platform")
    }
  end,
  latestBuild: latest_build && {
    id: latest_build.fetch("id"),
    version: latest_build.dig("attributes", "version"),
    uploadedDate: latest_build.dig("attributes", "uploadedDate"),
    processingState: latest_build.dig("attributes", "processingState"),
    expired: latest_build.dig("attributes", "expired"),
    usesNonExemptEncryption: latest_build.dig("attributes", "usesNonExemptEncryption")
  },
  iap: iaps.first && {
    id: iaps.first.fetch("id"),
    name: iaps.first.dig("attributes", "name"),
    productId: iaps.first.dig("attributes", "productId"),
    type: iaps.first.dig("attributes", "inAppPurchaseType"),
    state: iaps.first.dig("attributes", "state")
  }
}

puts JSON.pretty_generate(summary)

missing = []
missing << "appStoreVersion #{APP_VERSION}" if versions.empty?
missing << "uploaded build" unless latest_build
missing << "IAP #{PRODUCT_ID}" if iaps.empty?
abort "Missing ASC release state: #{missing.join(', ')}" unless missing.empty?
