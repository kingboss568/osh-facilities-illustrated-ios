# 職業安全衛生設施規則全圖解

已上架 iPhone / iPad App 的正式 Xcode 與 App Store 發行來源。

## 發行身分

- App Store Connect App ID：`6780516032`
- Bundle ID：`com.taiwanarch.oshfacilities.illustrated`
- App Store Connect 帳號：`jushiung@gmail.com`
- 團隊：`Yu Shiung Jiang`
- Scheme：`TaiwanBuildingCode`
- 目前更新目標：`1.1 (2)`
- 非消耗型內購：`com.taiwanarch.oshfacilities.illustrated.full`

## 1.1 功能

- GPT Image 一次生成、含繁體中文標題的低高度首頁 Banner。
- 首頁與圖卡快覽均使用真正的 250 筆條文搜尋。
- 五大分類直接進入 Pinterest 式直式雙欄圖卡瀏覽。
- 「條文」後新增「快覽」分頁，可持續上下滑動 250 張本機圖卡。
- Pro 按鈕統一為「Pro / 解鎖完整圖解」。
- 10 組共 100 個可操作工具，每個都有查核清單、風險速算、裝置端筆記與分享。

## 本機發行檢查

```zsh
./scripts/verify_1_1_update.sh
```

Xcode Cloud clone 後會執行相同檢查。StoreKit 測試設定只掛在 Run scheme，不會包進正式 App。

## 隱私與支援

App 內使用的隱私政策與支援頁來源位於 `AppStore/`，公開網站另在版本庫
`kingboss568/osh-facilities-law-support`。兩邊都必須版本控管並在送審前確認 HTTP 200。

## 發行狀態

以 `RELEASE_STATUS.md` 為單一事實來源。上傳成功不等於送審成功；必須以 App Store
Connect 的有效 Build、版本所選 Build、截圖組與 Review Submission 狀態為準。
