#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "time"
require "uri"
require "jwt"
require "digest/md5"

required = %w[ASC_ISSUER_ID ASC_KEY_ID ASC_KEY_FILE APP_IDENTIFIER]
missing = required.select { |key| ENV[key].to_s.strip.empty? }
abort "Missing required env vars: #{missing.join(', ')}" unless missing.empty?
abort "ASC_KEY_FILE does not exist: #{ENV.fetch("ASC_KEY_FILE")}" unless File.exist?(ENV.fetch("ASC_KEY_FILE"))

PRODUCT_ID = ENV.fetch("IAP_PRODUCT_ID", "com.taiwanarch.oshfacilities.illustrated.full")
REFERENCE_NAME = ENV.fetch("IAP_REFERENCE_NAME", "OSH Facilities Rules Illustrated Full Unlock")
DISPLAY_NAME = ENV.fetch("IAP_DISPLAY_NAME", "職業安全衛生設施規則全圖解 完整版")
DESCRIPTION = ENV.fetch("IAP_DESCRIPTION", "解鎖全部 250 張職安設施規則圖解、條文出處、常用條文、題庫測驗與書籤閱讀功能。")
REVIEW_NOTE = ENV.fetch("IAP_REVIEW_NOTE", "非消耗型一次買斷。購買後解鎖全部職安設施規則圖解與加值速查功能；前 20 張圖解可免費預覽。")
BASE_TERRITORY = ENV.fetch("IAP_BASE_TERRITORY", "TWN")
TARGET_PRICE = ENV.fetch("IAP_TARGET_CUSTOMER_PRICE", "390").to_f
REVIEW_SCREENSHOT = ENV.fetch(
  "IAP_REVIEW_SCREENSHOT",
  File.expand_path("../fastlane/screenshots/zh-Hant/ipad13_06_paywall.png", __dir__)
)

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

def request_json(method, path, query: {}, body: nil, allow_not_found: false)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  request = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri)
  request["Authorization"] = "Bearer #{TOKEN}"
  request["Content-Type"] = "application/json" if body
  request.body = JSON.generate(body) if body
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
  return nil if allow_not_found && response.code == "404"
  return parsed if response.is_a?(Net::HTTPSuccess)

  details = parsed["errors"] || parsed
  abort "ASC API #{response.code} #{method.upcase} #{uri}: #{JSON.pretty_generate(details)}"
end

def get_json(path, query = {})
  request_json("get", path, query: query)
end

def post_json(path, body)
  request_json("post", path, body: body)
end

def patch_json(path, body)
  request_json("patch", path, body: body)
end

def delete_json(path)
  request_json("delete", path)
end

def first_app!
  apps = get_json(
    "/v1/apps",
    {
      "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"),
      "fields[apps]" => "name,bundleId,sku,primaryLocale"
    }
  ).fetch("data")
  abort "No App Store Connect app found for bundle id #{ENV.fetch("APP_IDENTIFIER")}" if apps.empty?

  apps.first
end

def find_iap(app_id)
  get_json(
    "/v1/apps/#{app_id}/inAppPurchasesV2",
    {
      "filter[productId]" => PRODUCT_ID,
      "fields[inAppPurchases]" => "name,productId,inAppPurchaseType,state,reviewNote,familySharable,contentHosting"
    }
  ).fetch("data").first
end

def create_iap(app_id)
  post_json(
    "/v2/inAppPurchases",
    {
      data: {
        type: "inAppPurchases",
        attributes: {
          name: REFERENCE_NAME,
          productId: PRODUCT_ID,
          inAppPurchaseType: "NON_CONSUMABLE",
          reviewNote: REVIEW_NOTE,
          familySharable: true
        },
        relationships: {
          app: {
            data: {
              type: "apps",
              id: app_id
            }
          }
        }
      }
    }
  ).fetch("data")
end

def ensure_localization(iap_id)
  existing = get_json(
    "/v2/inAppPurchases/#{iap_id}/inAppPurchaseLocalizations",
    {
      "fields[inAppPurchaseLocalizations]" => "name,locale,description,state"
    }
  ).fetch("data")
  zh = existing.find { |row| row.dig("attributes", "locale") == "zh-Hant" || row.dig("attributes", "locale") == "zh-TW" }
  return zh if zh

  post_json(
    "/v1/inAppPurchaseLocalizations",
    {
      data: {
        type: "inAppPurchaseLocalizations",
        attributes: {
          name: DISPLAY_NAME,
          locale: "zh-Hant",
          description: DESCRIPTION
        },
        relationships: {
          inAppPurchaseV2: {
            data: {
              type: "inAppPurchases",
              id: iap_id
            }
          }
        }
      }
    }
  ).fetch("data")
end

def current_price_schedule(iap_id)
  request_json(
    "get",
    "/v2/inAppPurchases/#{iap_id}/iapPriceSchedule",
    query: {
      "include" => "baseTerritory,manualPrices,automaticPrices",
      "fields[inAppPurchasePrices]" => "startDate,endDate,manual,inAppPurchasePricePoint,territory",
      "fields[territories]" => "currency",
      "limit[manualPrices]" => "50",
      "limit[automaticPrices]" => "50"
    },
    allow_not_found: true
  )
end

def price_schedule_set?(schedule)
  return false unless schedule

  Array(schedule["included"]).any? { |row| row["type"] == "inAppPurchasePrices" }
end

def matching_price_point(iap_id)
  points = get_json(
    "/v2/inAppPurchases/#{iap_id}/pricePoints",
    {
      "filter[territory]" => BASE_TERRITORY,
      "fields[inAppPurchasePricePoints]" => "customerPrice,proceeds,territory",
      "include" => "territory",
      "limit" => "8000"
    }
  ).fetch("data")

  exact = points.find do |point|
    point.dig("attributes", "customerPrice").to_f == TARGET_PRICE
  end
  exact || abort("No #{BASE_TERRITORY} price point matched customerPrice #{TARGET_PRICE.to_i} for #{PRODUCT_ID}")
end

def ensure_price_schedule(iap_id)
  schedule = current_price_schedule(iap_id)
  return schedule if price_schedule_set?(schedule)

  point = matching_price_point(iap_id)
  price_id = "${manual-price-#{BASE_TERRITORY.downcase}-#{TARGET_PRICE.to_i}}"
  post_json(
    "/v1/inAppPurchasePriceSchedules",
    {
      data: {
        type: "inAppPurchasePriceSchedules",
        relationships: {
          inAppPurchase: {
            data: {
              type: "inAppPurchases",
              id: iap_id
            }
          },
          baseTerritory: {
            data: {
              type: "territories",
              id: BASE_TERRITORY
            }
          },
          manualPrices: {
            data: [
              {
                type: "inAppPurchasePrices",
                id: price_id
              }
            ]
          }
        }
      },
      included: [
        {
          type: "inAppPurchasePrices",
          id: price_id,
          attributes: {
            startDate: nil,
            endDate: nil
          },
          relationships: {
            inAppPurchaseV2: {
              data: {
                type: "inAppPurchases",
                id: iap_id
              }
            },
            inAppPurchasePricePoint: {
              data: {
                type: "inAppPurchasePricePoints",
                id: point.fetch("id")
              }
            }
          }
        }
      ]
    }
  )
end

def upload_asset_operations(operations, bytes)
  operations.each do |operation|
    uri = URI(operation.fetch("url"))
    request = Net::HTTPGenericRequest.new(
      operation.fetch("method"),
      true,
      true,
      uri.request_uri
    )
    Array(operation["requestHeaders"]).each do |header|
      request[header.fetch("name")] = header.fetch("value")
    end
    request.body = bytes[operation.fetch("offset"), operation.fetch("length")]
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(request) }
    next if response.is_a?(Net::HTTPSuccess)

    abort "Asset upload failed #{response.code} #{operation.fetch("method")} #{uri}: #{response.body}"
  end
end

def review_screenshot(iap_id)
  request_json(
    "get",
    "/v2/inAppPurchases/#{iap_id}/appStoreReviewScreenshot",
    query: {
      "fields[inAppPurchaseAppStoreReviewScreenshots]" => "fileSize,fileName,sourceFileChecksum,imageAsset,assetDeliveryState,uploadOperations"
    },
    allow_not_found: true
  )
end

def screenshot_complete?(screenshot)
  screenshot&.dig("data", "attributes", "assetDeliveryState", "state") == "COMPLETE"
end

def ensure_review_screenshot(iap_id)
  abort "IAP_REVIEW_SCREENSHOT does not exist: #{REVIEW_SCREENSHOT}" unless File.exist?(REVIEW_SCREENSHOT)

  bytes = File.binread(REVIEW_SCREENSHOT)
  checksum = Digest::MD5.hexdigest(bytes)
  existing = review_screenshot(iap_id)
  if screenshot_complete?(existing)
    existing_checksum = existing.dig("data", "attributes", "sourceFileChecksum")
    return existing.fetch("data") if existing_checksum == checksum

    delete_json("/v1/inAppPurchaseAppStoreReviewScreenshots/#{existing.dig("data", "id")}")
  end

  created = post_json(
    "/v1/inAppPurchaseAppStoreReviewScreenshots",
    {
      data: {
        type: "inAppPurchaseAppStoreReviewScreenshots",
        attributes: {
          fileSize: bytes.bytesize,
          fileName: File.basename(REVIEW_SCREENSHOT)
        },
        relationships: {
          inAppPurchaseV2: {
            data: {
              type: "inAppPurchases",
              id: iap_id
            }
          }
        }
      }
    }
  ).fetch("data")

  operations = created.dig("attributes", "uploadOperations")
  abort "ASC did not return upload operations for IAP review screenshot #{created.fetch("id")}" if Array(operations).empty?

  upload_asset_operations(operations, bytes)
  patched = patch_json(
    "/v1/inAppPurchaseAppStoreReviewScreenshots/#{created.fetch("id")}",
    {
      data: {
        type: "inAppPurchaseAppStoreReviewScreenshots",
        id: created.fetch("id"),
        attributes: {
          uploaded: true,
          sourceFileChecksum: checksum
        }
      }
    }
  ).fetch("data")

  20.times do
    state = patched.dig("attributes", "assetDeliveryState", "state")
    break if state == "COMPLETE" || state == "FAILED"

    sleep 2
    patched = request_json(
      "get",
      "/v1/inAppPurchaseAppStoreReviewScreenshots/#{created.fetch("id")}",
      query: {
        "fields[inAppPurchaseAppStoreReviewScreenshots]" => "fileSize,fileName,sourceFileChecksum,imageAsset,assetDeliveryState"
      }
    ).fetch("data")
  end

  state = patched.dig("attributes", "assetDeliveryState", "state")
  abort "IAP review screenshot processing failed: #{JSON.pretty_generate(patched.dig("attributes", "assetDeliveryState"))}" if state == "FAILED"

  patched
end

def territory_ids
  ids = []
  cursor = nil
  loop do
    query = { "limit" => "200", "fields[territories]" => "currency" }
    query["cursor"] = cursor if cursor
    response = get_json("/v1/territories", query)
    ids.concat(response.fetch("data").map { |row| row.fetch("id") })
    next_link = response.dig("links", "next")
    break unless next_link

    cursor = URI.decode_www_form(URI(next_link).query.to_s).to_h["cursor"]
    break unless cursor
  end

  ids.empty? ? [BASE_TERRITORY] : ids
end

def availability(iap_id)
  request_json(
    "get",
    "/v2/inAppPurchases/#{iap_id}/inAppPurchaseAvailability",
    query: {
      "fields[inAppPurchaseAvailabilities]" => "availableInNewTerritories,availableTerritories",
      "limit[availableTerritories]" => "50"
    },
    allow_not_found: true
  )
end

def ensure_availability(iap_id)
  existing = availability(iap_id)
  return existing.fetch("data") if existing&.dig("data", "id")

  territories = territory_ids.map do |territory_id|
    {
      type: "territories",
      id: territory_id
    }
  end

  post_json(
    "/v1/inAppPurchaseAvailabilities",
    {
      data: {
        type: "inAppPurchaseAvailabilities",
        attributes: {
          availableInNewTerritories: true
        },
        relationships: {
          inAppPurchase: {
            data: {
              type: "inAppPurchases",
              id: iap_id
            }
          },
          availableTerritories: {
            data: territories
          }
        }
      }
    }
  ).fetch("data")
end

app = first_app!
iap = find_iap(app.fetch("id"))
created = false
unless iap
  iap = create_iap(app.fetch("id"))
  created = true
end

localization = ensure_localization(iap.fetch("id"))
schedule = ensure_price_schedule(iap.fetch("id"))
review_screenshot_data = ensure_review_screenshot(iap.fetch("id"))
availability_data = ensure_availability(iap.fetch("id"))
final_iap = get_json(
  "/v2/inAppPurchases/#{iap.fetch("id")}",
  {
    "include" => "inAppPurchaseLocalizations,iapPriceSchedule",
    "fields[inAppPurchases]" => "name,productId,inAppPurchaseType,state,reviewNote,familySharable,contentHosting"
  }
).fetch("data")

puts JSON.pretty_generate(
  app: {
    id: app.fetch("id"),
    name: app.dig("attributes", "name"),
    bundleId: app.dig("attributes", "bundleId"),
    sku: app.dig("attributes", "sku")
  },
  iap: {
    id: final_iap.fetch("id"),
    created: created,
    name: final_iap.dig("attributes", "name"),
    productId: final_iap.dig("attributes", "productId"),
    type: final_iap.dig("attributes", "inAppPurchaseType"),
    state: final_iap.dig("attributes", "state"),
    familySharable: final_iap.dig("attributes", "familySharable")
  },
  localization: {
    id: localization.fetch("id"),
    locale: localization.dig("attributes", "locale"),
    name: localization.dig("attributes", "name")
  },
  priceSchedule: {
    id: schedule.dig("data", "id"),
    configured: price_schedule_set?(schedule),
    baseTerritory: BASE_TERRITORY,
    targetCustomerPrice: TARGET_PRICE.to_i
  },
  reviewScreenshot: {
    id: review_screenshot_data.fetch("id"),
    fileName: review_screenshot_data.dig("attributes", "fileName"),
    state: review_screenshot_data.dig("attributes", "assetDeliveryState", "state"),
    checksum: review_screenshot_data.dig("attributes", "sourceFileChecksum")
  },
  availability: {
    id: availability_data.fetch("id"),
    availableInNewTerritories: availability_data.dig("attributes", "availableInNewTerritories")
  }
)
