#!/bin/bash
# 建築技術規則全圖解 — 一鍵建置 Xcode 專案
# 雙擊即可執行
set -e
cd "$(dirname "$0")"

echo "════════════════════════════════════════"
echo "  建築技術規則全圖解 — 一鍵建置"
echo "  @iOS-Dev for @Jiang"
echo "════════════════════════════════════════"
echo ""

# Step 1: 確認 Xcode
echo "▶ Step 1/5：確認 Xcode 已安裝..."
if ! xcode-select -p &> /dev/null || [ ! -d "/Applications/Xcode.app" ]; then
  echo "❌ Xcode 未安裝！"
  echo ""
  echo "請先做下面任一個："
  echo "  A. 從 App Store 下載 Xcode（12GB，約 30–60 分鐘）"
  echo "     https://apps.apple.com/tw/app/xcode/id497799835"
  echo "  B. 切換到有 Xcode 的另一台 Mac，把整個資料夾複製過去再雙擊本檔"
  echo ""
  read -n 1 -s -r -p "按任意鍵結束..."
  exit 1
fi
echo "  ✓ Xcode 已安裝在 $(xcode-select -p)"
echo ""

# Step 2: 確認 Homebrew + xcodegen
echo "▶ Step 2/5：確認 xcodegen..."
if ! command -v xcodegen &> /dev/null; then
  echo "  ⚠ 未安裝 xcodegen，自動嘗試安裝..."
  if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew 也未安裝。請先在終端機執行："
    echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    read -n 1 -s -r -p "按任意鍵結束..."
    exit 1
  fi
  brew install xcodegen
fi
echo "  ✓ xcodegen $(xcodegen version | head -1)"
echo ""

# Step 3: 複製 163 張圖檔（如尚未複製）
IMG_DST="TaiwanBuildingCode/Resources/images"
IMG_SRC="$HOME/Documents/江毓祥資料庫/大腦系統/資源共享/建築技術規則_iOS開發包/images"
echo "▶ Step 3/5：複製 163 張圖檔..."
mkdir -p "$IMG_DST"
EXISTING=$(ls "$IMG_DST" 2>/dev/null | wc -l | tr -d ' ')
if [ "$EXISTING" -lt 163 ]; then
  if [ ! -d "$IMG_SRC" ]; then
    echo "❌ 找不到圖檔來源：$IMG_SRC"
    read -n 1 -s -r -p "按任意鍵結束..."
    exit 1
  fi
  echo "  從 $IMG_SRC 複製..."
  cp -R "$IMG_SRC/"* "$IMG_DST/"
  echo "  ✓ 已複製 $(ls "$IMG_DST" | wc -l | tr -d ' ') 張圖檔"
else
  echo "  ✓ 圖檔已存在（$EXISTING 張），跳過複製"
fi
echo ""

# Step 4: 建立 LaunchScreen 顏色 + Asset Catalog
echo "▶ Step 4/5：建立 Asset Catalog..."
ASSETS="TaiwanBuildingCode/Resources/Assets.xcassets"
mkdir -p "$ASSETS/AppIcon.appiconset"
mkdir -p "$ASSETS/AccentColor.colorset"
mkdir -p "$ASSETS/LaunchScreenBG.colorset"

# Asset catalog root
cat > "$ASSETS/Contents.json" <<'JSON'
{ "info" : { "author" : "xcode", "version" : 1 } }
JSON

# AppIcon — 引用 icon-1024.png（如已存在）
ICON_FILE="$ASSETS/AppIcon.appiconset/icon-1024.png"
if [ -f "$ICON_FILE" ]; then
  cat > "$ASSETS/AppIcon.appiconset/Contents.json" <<'JSON'
{
  "images" : [
    { "filename" : "icon-1024.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON
else
  cat > "$ASSETS/AppIcon.appiconset/Contents.json" <<'JSON'
{
  "images" : [
    { "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON
fi

# Accent color：磚紅
cat > "$ASSETS/AccentColor.colorset/Contents.json" <<'JSON'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : { "alpha" : "1.000", "blue" : "0.224", "green" : "0.318", "red" : "0.722" }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON

# Launch screen background：淺灰
cat > "$ASSETS/LaunchScreenBG.colorset/Contents.json" <<'JSON'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : { "alpha" : "1.000", "blue" : "0.97", "green" : "0.97", "red" : "0.97" }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON

echo "  ✓ Asset Catalog 建好"
echo ""

# Step 5: 跑 xcodegen + open Xcode
echo "▶ Step 5/5：用 xcodegen 生成 .xcodeproj..."
xcodegen generate

if [ ! -d "TaiwanBuildingCode.xcodeproj" ]; then
  echo "❌ xcodegen 沒生出 .xcodeproj"
  read -n 1 -s -r -p "按任意鍵結束..."
  exit 1
fi

echo "  ✓ TaiwanBuildingCode.xcodeproj 建好"
echo ""
echo "════════════════════════════════════════"
echo "  ✅ 全部完成！正在開啟 Xcode..."
echo "════════════════════════════════════════"
echo ""
echo "Xcode 開啟後，請按 ⌘R 跑 Simulator。"
echo "首次 build 需 1–3 分鐘（要把 163 張圖檔載進 Asset bundle）。"
echo ""

open TaiwanBuildingCode.xcodeproj

read -n 1 -s -r -p "按任意鍵關閉這個視窗..."
