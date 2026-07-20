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

product_id = ENV.fetch("IAP_PRODUCT_ID", "com.taiwanarch.oshfacilities.illustrated.full")
reference_name = ENV.fetch("IAP_REFERENCE_NAME", "OSH Facilities Rules Illustrated Full Unlock")

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

def request_json(method, path, token, body: nil, query: {})
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  request = method.new(uri)
  request["Authorization"] = "Bearer #{token}"
  if body
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(body)
  end
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
  unless response.is_a?(Net::HTTPSuccess)
    abort "ASC API #{response.code} for #{uri}: #{JSON.pretty_generate(parsed)}"
  end
  parsed
end

apps = request_json(
  Net::HTTP::Get,
  "/v1/apps",
  token,
  query: {
    "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"),
    "fields[apps]" => "name,bundleId,sku,primaryLocale"
  }
).fetch("data")
abort "No ASC app found for bundle id #{ENV.fetch("APP_IDENTIFIER")}" if apps.empty?

app = apps.first
existing = request_json(
  Net::HTTP::Get,
  "/v1/apps/#{app.fetch("id")}/inAppPurchasesV2",
  token,
  query: {
    "filter[productId]" => product_id,
    "fields[inAppPurchases]" => "name,productId,inAppPurchaseType,state,reviewNote,familySharable,contentHosting"
  }
).fetch("data")

if existing.any?
  puts JSON.pretty_generate(status: "exists", app: app.fetch("id"), iap: existing.first)
  exit 0
end

created = request_json(
  Net::HTTP::Post,
  "/v2/inAppPurchases",
  token,
  body: {
    data: {
      type: "inAppPurchases",
      attributes: {
        name: reference_name,
        productId: product_id,
        inAppPurchaseType: "NON_CONSUMABLE",
        familySharable: true,
        reviewNote: "一次買斷解鎖職業安全衛生設施規則全圖解完整內容：250 張圖解、條文摘要、常用法條與題庫測驗。"
      },
      relationships: {
        app: {
          data: {
            type: "apps",
            id: app.fetch("id")
          }
        }
      }
    }
  }
)

puts JSON.pretty_generate(status: "created", app: app.fetch("id"), iap: created.fetch("data"))
