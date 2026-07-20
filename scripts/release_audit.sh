#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env.fastlane" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env.fastlane"
  set +a
fi

PASS=0
FAIL=0
WARN=0

pass() { printf '[PASS] %s\n' "$*"; PASS=$((PASS + 1)); }
fail() { printf '[FAIL] %s\n' "$*"; FAIL=$((FAIL + 1)); }
warn() { printf '[WARN] %s\n' "$*"; WARN=$((WARN + 1)); }

check_file() {
  local path="$1"
  [[ -f "$path" ]] && pass "file exists: $path" || fail "missing file: $path"
}

check_url_200() {
  local url="$1"
  local code
  code="$(curl -L -s -o /dev/null -w '%{http_code}' "$url" || true)"
  [[ "$code" == "200" ]] && pass "HTTP 200: $url" || fail "HTTP $code: $url"
}

printf 'Release audit for %s\n\n' "${APP_IDENTIFIER:-com.taiwanarch.oshfacilities.illustrated}"

check_file "TaiwanBuildingCode/Resources/Info.plist"
check_file "TaiwanBuildingCode/Resources/PrivacyInfo.xcprivacy"
check_file "TaiwanBuildingCode/Resources/Configuration.storekit"
check_file "TaiwanBuildingCode/Resources/data/articles.json"
check_file "ExportOptions-AppStore-Manual.plist"
check_file "Docs/AppStore/app-store-listing.md"
check_file "scripts/upload_after_comet_app_record.sh"
check_file "scripts/check_asc_app_record.rb"
check_file "scripts/check_asc_release_state.rb"
check_file "${IPA_PATH:-build/export-appstore/職業安全衛生設施規則全圖解.ipa}"

if plutil -lint TaiwanBuildingCode/Resources/Info.plist >/dev/null; then
  pass "Info.plist lint"
else
  fail "Info.plist lint"
fi

if plutil -lint TaiwanBuildingCode/Resources/PrivacyInfo.xcprivacy >/dev/null; then
  pass "PrivacyInfo.xcprivacy lint"
else
  fail "PrivacyInfo.xcprivacy lint"
fi

if python3 -m json.tool TaiwanBuildingCode/Resources/Configuration.storekit >/dev/null 2>&1; then
  pass "Configuration.storekit JSON parse"
else
  fail "Configuration.storekit JSON parse"
fi

privacy_collected_count="$(python3 - <<'PY'
import plistlib
from pathlib import Path
data=plistlib.loads(Path("TaiwanBuildingCode/Resources/PrivacyInfo.xcprivacy").read_bytes())
print(len(data.get("NSPrivacyCollectedDataTypes", [])))
PY
)"
[[ "$privacy_collected_count" == "0" ]] && pass "PrivacyInfo collected data count = 0" || fail "PrivacyInfo collected data count = $privacy_collected_count"

iap_display_value="${IAP_DISPLAY_NAME:-}"
iap_display_len="${#iap_display_value}"
if [[ -n "$iap_display_value" && "$iap_display_len" -ge 2 && "$iap_display_len" -le 30 ]]; then
  pass "IAP display name length"
else
  fail "IAP display name length = $iap_display_len"
fi

iap_description_value="${IAP_DESCRIPTION:-}"
iap_description_len="${#iap_description_value}"
if [[ -n "$iap_description_value" && "$iap_description_len" -le 45 ]]; then
  pass "IAP description length"
else
  fail "IAP description length = $iap_description_len"
fi

article_count="$(python3 - <<'PY'
import json
from pathlib import Path
data=json.loads(Path("TaiwanBuildingCode/Resources/data/articles.json").read_text())
print(len(data.get("articles", [])))
PY
)"
[[ "$article_count" == "250" ]] && pass "articles count = 250" || fail "articles count = $article_count"

image_count="$(find TaiwanBuildingCode/Resources/images -maxdepth 1 -type f -name 'OSH-*.heic' | wc -l | tr -d ' ')"
[[ "$image_count" == "250" ]] && pass "resource HEIC image count = 250" || fail "resource HEIC image count = $image_count"

shot_count="$(find fastlane/screenshots/zh-Hant -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
[[ "$shot_count" == "12" ]] && pass "screenshot count = 12" || fail "screenshot count = $shot_count"

bad_screenshots="$(
  python3 - <<'PY'
from pathlib import Path
from PIL import Image
expected = {
  "iphone69": (1320, 2868),
  "ipad13": (2064, 2752),
}
bad=[]
for path in sorted(Path("fastlane/screenshots/zh-Hant").glob("*.png")):
    prefix = path.name.split("_", 1)[0]
    with Image.open(path) as im:
        if expected.get(prefix) != im.size:
            bad.append(f"{path.name}:{im.size[0]}x{im.size[1]}")
print("\n".join(bad))
PY
)"
[[ -z "$bad_screenshots" ]] && pass "screenshot dimensions" || fail "bad screenshot dimensions: $bad_screenshots"

for url in \
  "https://kingboss568.github.io/osh-facilities-law-support/" \
  "https://kingboss568.github.io/osh-facilities-law-support/privacy.html" \
  "https://kingboss568.github.io/osh-facilities-law-support/support.html"
do
  check_url_200 "$url"
done

ipa_path="${IPA_PATH:-build/export-appstore/職業安全衛生設施規則全圖解.ipa}"
if [[ -f "$ipa_path" ]]; then
  tmp="/tmp/osh-facilities-release-audit-ipa"
  rm -rf "$tmp"
  mkdir -p "$tmp"
  if unzip -q "$ipa_path" -d "$tmp"; then
    pass "IPA unzip"
    app="$tmp/Payload/TaiwanBuildingCode.app"
    ipa_bundle="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist" 2>/dev/null || true)"
    ipa_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$app/Info.plist" 2>/dev/null || true)"
    ipa_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Info.plist" 2>/dev/null || true)"
    ipa_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist" 2>/dev/null || true)"
    expected_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' TaiwanBuildingCode/Resources/Info.plist 2>/dev/null || true)"
    expected_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' TaiwanBuildingCode/Resources/Info.plist 2>/dev/null || true)"
    [[ "$ipa_bundle" == "${APP_IDENTIFIER:-com.taiwanarch.oshfacilities.illustrated}" ]] && pass "IPA bundle id" || fail "IPA bundle id = $ipa_bundle"
    [[ "$ipa_name" == "職業安全衛生設施規則全圖解" ]] && pass "IPA display name" || fail "IPA display name = $ipa_name"
    [[ "$ipa_version" == "$expected_version" && "$ipa_build" == "$expected_build" ]] && pass "IPA version/build $expected_version/$expected_build" || fail "IPA version/build = $ipa_version/$ipa_build expected $expected_version/$expected_build"
    ipa_images="$(find "$app" -maxdepth 1 -type f -name 'OSH-*.heic' | wc -l | tr -d ' ')"
    [[ "$ipa_images" == "250" ]] && pass "IPA HEIC image count = 250" || fail "IPA HEIC image count = $ipa_images"
    sign_info="$(/usr/bin/codesign -dv --verbose=4 "$app" 2>&1 || true)"
    printf '%s\n' "$sign_info" | grep -q 'Authority=Apple Distribution: Yu Shiung Jiang' && pass "IPA Apple Distribution signature" || fail "IPA Apple Distribution signature"
    entitlements_file="$tmp/entitlements.plist"
    if /usr/bin/codesign -d --entitlements :- "$app" >"$entitlements_file" 2>/dev/null; then
      task_allow="$(plutil -extract get-task-allow raw -o - "$entitlements_file" 2>/dev/null || true)"
      [[ "$task_allow" == "false" ]] && pass "IPA get-task-allow=false" || fail "IPA get-task-allow=$task_allow"
    else
      fail "IPA entitlements extraction"
    fi
  else
    fail "IPA unzip"
  fi
fi

if [[ -d "$PROJECT_ROOT/隱私政策-osh-facilities-law-support/.git" ]]; then
  if git -C "$PROJECT_ROOT/隱私政策-osh-facilities-law-support" status --short | grep -q .; then
    warn "support-page git repo has uncommitted changes"
  else
    pass "support-page git repo clean"
  fi
else
  fail "support-page git repo missing"
fi

if [[ -n "${ASC_ISSUER_ID:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_KEY_FILE:-}" && -n "${APP_IDENTIFIER:-}" ]]; then
  if ruby scripts/check_asc_app_record.rb >/tmp/osh-facilities-asc-app-record.json 2>/tmp/osh-facilities-asc-app-record.err; then
    pass "ASC app record exists"
    if ruby scripts/check_asc_iap.rb >/tmp/osh-facilities-asc-iap.json 2>/tmp/osh-facilities-asc-iap.err; then
      pass "ASC IAP exists"
    else
      warn "ASC IAP not verified: $(cat /tmp/osh-facilities-asc-iap.err)"
    fi
    if ruby scripts/check_asc_release_state.rb >/tmp/osh-facilities-asc-release-state.json 2>/tmp/osh-facilities-asc-release-state.err; then
      pass "ASC release state verified"
    else
      warn "ASC release state not verified: $(cat /tmp/osh-facilities-asc-release-state.err)"
    fi
  else
    warn "ASC app record not found: $(cat /tmp/osh-facilities-asc-app-record.err)"
  fi
else
  warn "ASC env incomplete; skipped ASC app/IAP checks"
fi

printf '\nSummary: PASS=%s FAIL=%s WARN=%s\n' "$PASS" "$FAIL" "$WARN"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi

exit 0
