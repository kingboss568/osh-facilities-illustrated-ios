# RELEASE STATUS

最後更新：2026-07-21（Asia/Taipei）

## 身分契約

- App：職業安全衛生設施規則全圖解
- App Store Connect App ID：`6780516032`
- Bundle ID：`com.taiwanarch.oshfacilities.illustrated`
- ASC 帳號 / 團隊：`jushiung@gmail.com` / `Yu Shiung Jiang`
- 送審版本：`1.1 (7)`
- IAP：`6780516552` / `com.taiwanarch.oshfacilities.illustrated.full`

## 目前事實

- App Store 正式版：`1.0 (1)` / `READY_FOR_SALE`
- 正式版 Build：`VALID`
- IAP：`APPROVED`
- 1.1 原始碼：功能完成
- 1.1 無簽名 App + Unit/UI test targets：Xcode 27 beta 編譯成功
- 1.1 自動測試：3 個 Unit + 5 個 UI 全數通過，0 failure
- `scripts/verify_1_1_update.sh`：0 failure
- 1.1 中繼資料：已上傳 ASC
- 1.1 截圖：iPhone 6.9 與 iPad 13 各 6 張，live ASC 均為 `COMPLETE`
- Xcode Cloud 關聯：已在 `Yu Shiung Jiang` 帳號線重建成功；ciProduct `0e91a40a-2494-4fa5-961e-6ef77b5f05c0`
- Xcode Cloud 工作流程：`Default` / `A292E575-C716-4540-A93A-83E65FB3C0EA`，單一 `Archive - iOS → App Store Connect`
- Xcode Cloud Build 7：run `8015416c-82cf-412e-85eb-8cbb4d5d7c35`，Archive、App Store export 與 Prepare Build for App Store Connect 全數通過
- ASC Build：`1.1 (7)` / `fbf510df-bcb6-4515-bfa1-734d5b23a466` / `VALID` / 未過期 / `usesNonExemptEncryption=false`
- 1.1 所選 Build：`1.1 (7)`
- Fastlane：metadata、screenshots、選取 Build 與 submit review 均已完成
- Review Submission：`4f274735-bcbc-4bdb-bba7-b7b83b48fd56` / `WAITING_FOR_REVIEW`，提交時間 `2026-07-21 19:44:35`（Asia/Taipei）
- App Store version 1.1：`WAITING_FOR_REVIEW`

## 1.1 必交契約

- 250 筆 articles.json + 250 張 HEIC
- 低高度、繁體中文文字與畫面一次生成的 GPT Image Banner
- 首頁真正搜尋 + 可點入結果
- 五大分類直接進入直式雙欄圖卡
- 新增「快覽」分頁，位於「條文」之後
- 100 個唯一工具，全部可開啟與操作
- iPhone 6.9 截圖 6 張、iPad 13 截圖 6 張
- App 1.1 與有效 Build 綁定
- 最終以 Review Submission 與版本狀態確認送審

## 當前發行 Gate

功能、測試、截圖、Cloud Archive、ASC Build 與送審 Gate 已通過。後續只監看
App Review 狀態；不得把 Cloud 成功或上傳成功單獨當成送審證據，本次完成證據是
版本 `WAITING_FOR_REVIEW`、Build 7 `VALID` 且已選入版本，以及 Review Submission
`4f274735-bcbc-4bdb-bba7-b7b83b48fd56`。
