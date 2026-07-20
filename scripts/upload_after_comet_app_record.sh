#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env.fastlane" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env.fastlane"
  set +a
fi

: "${APP_IDENTIFIER:?APP_IDENTIFIER is required}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID is required}"
: "${ASC_KEY_ID:?ASC_KEY_ID is required}"
: "${ASC_KEY_FILE:?ASC_KEY_FILE is required}"
: "${IPA_PATH:?IPA_PATH is required}"
: "${IAP_PRODUCT_ID:?IAP_PRODUCT_ID is required}"

[[ -f "$ASC_KEY_FILE" ]] || { echo "ASC_KEY_FILE does not exist: $ASC_KEY_FILE"; exit 1; }
[[ -f "$IPA_PATH" ]] || { echo "IPA_PATH does not exist: $IPA_PATH"; exit 1; }
[[ -f "${IAP_REVIEW_SCREENSHOT:-}" ]] || { echo "IAP_REVIEW_SCREENSHOT does not exist: ${IAP_REVIEW_SCREENSHOT:-}"; exit 1; }
command -v fastlane >/dev/null 2>&1 || { echo "fastlane not found. Run: brew install fastlane"; exit 1; }

echo "[0/8] Verify public support/privacy URLs"
for url in \
  "https://kingboss568.github.io/osh-facilities-law-support/" \
  "https://kingboss568.github.io/osh-facilities-law-support/privacy.html" \
  "https://kingboss568.github.io/osh-facilities-law-support/support.html"
do
  code="$(curl -L -s -o /dev/null -w '%{http_code}' "$url")"
  [[ "$code" == "200" ]] || { echo "URL failed HTTP $code: $url"; exit 1; }
  echo "  HTTP 200 $url"
done

echo "[1/8] Verify screenshots"
shot_count="$(find fastlane/screenshots/zh-Hant -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
[[ "$shot_count" -ge 12 ]] || { echo "Expected at least 12 screenshots, found $shot_count"; exit 1; }
echo "  screenshots=$shot_count"

echo "[2/8] Verify ASC app record exists"
ruby scripts/check_asc_app_record.rb

echo "[3/8] Create/update IAP, localization, price, review screenshot, availability"
ruby scripts/setup_asc_iap.rb

echo "[4/8] Upload metadata"
fastlane ios deliver_metadata

echo "[5/8] Upload screenshots"
fastlane ios deliver_screenshots

echo "[6/8] Upload IPA"
fastlane ios deliver_ipa ipa:"$IPA_PATH"

echo "[7/8] Verify IAP state after upload"
ruby scripts/check_asc_iap.rb

echo "[8/8] Verify ASC release state"
ruby scripts/check_asc_release_state.rb

echo "Done. Open App Store Connect in Comet to select the processed build, attach IAP to version review if needed, verify App Privacy, and submit for review."
