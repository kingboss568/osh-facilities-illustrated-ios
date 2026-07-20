#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/TaiwanBuildingCode"
FAILURES=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1"
  FAILURES=$((FAILURES + 1))
}

check_equal() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label = $expected"
  else
    fail "$label expected $expected, got $actual"
  fi
}

article_count="$(jq -r '.articles | length' "$SOURCE/Resources/data/articles.json")"
image_count="$(find "$SOURCE/Resources/images" -type f -name 'OSH-*.heic' ! -name '._*' | wc -l | tr -d ' ')"
tool_count="$(awk -F'"' '/^                \("/ { count += 1 } END { print count + 0 }' "$SOURCE/Models/SafetyTool.swift")"
unique_tool_titles="$(awk -F'"' '/^                \("/ { print $2 }' "$SOURCE/Models/SafetyTool.swift" | sort -u | wc -l | tr -d ' ')"
tool_group_count="$(awk -F'"' '/^            \("[^"]+", \[$/ { count += 1 } END { print count + 0 }' "$SOURCE/Models/SafetyTool.swift")"

check_equal "article catalog" "$article_count" "250"
check_equal "HEIC illustrations" "$image_count" "250"
check_equal "tool catalog" "$tool_count" "100"
check_equal "unique tool titles" "$unique_tool_titles" "100"
check_equal "tool groups" "$tool_group_count" "10"

rg -q 'home-search-field' "$SOURCE/Views/Tab1_Illustrations/IllustrationsHomeView.swift" \
  && pass "home search field is wired" \
  || fail "home search field missing"

rg -q 'store\.search\(query\)' "$SOURCE/Views/Tab1_Illustrations/IllustrationsHomeView.swift" \
  && pass "home search uses ArticleStore results" \
  || fail "home search does not use ArticleStore"

rg -q 'case 2: GalleryView\(\)' "$SOURCE/App/ContentView.swift" \
  && pass "gallery tab inserted after full text" \
  || fail "gallery tab order missing"

rg -q 'SeriesGalleryView\(seriesId:' "$SOURCE/Views/Tab1_Illustrations/IllustrationsHomeView.swift" \
  && pass "five-category routes use gallery" \
  || fail "category gallery route missing"

rg -q 'PinterestArticleGrid' "$SOURCE/Views/Tab3_Gallery/GalleryView.swift" \
  && pass "Pinterest two-column gallery exists" \
  || fail "Pinterest gallery missing"

rg -q 'SafetyToolDetailView\(tool:' "$SOURCE/Views/Tab4_Calculators/SafetyToolsView.swift" \
  && pass "all tool cards route to a functional detail" \
  || fail "tool detail route missing"

rg -q 'tool-risk-result' "$SOURCE/Views/Tab4_Calculators/SafetyToolsView.swift" \
  && pass "tool risk calculator exists" \
  || fail "tool risk calculator missing"

if plutil -lint "$SOURCE/Resources/PrivacyInfo.xcprivacy" >/dev/null; then
  pass "PrivacyInfo.xcprivacy is valid"
else
  fail "PrivacyInfo.xcprivacy is invalid"
fi

if rg -q 'Configuration\.storekit in Resources' "$ROOT/OSHFacilitiesIllustrated.xcodeproj/project.pbxproj"; then
  fail "Configuration.storekit is packaged in the app"
else
  pass "Configuration.storekit is excluded from app resources"
fi

if git -C "$ROOT" diff --check; then
  pass "git diff whitespace check"
else
  fail "git diff whitespace check"
fi

printf 'Release gate: %d failure(s)\n' "$FAILURES"
exit "$FAILURES"
