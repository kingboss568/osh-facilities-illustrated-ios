# RELEASE STATUS

最後更新：2026-07-21（Asia/Taipei）

## 身分契約

- App：職業安全衛生設施規則全圖解
- App Store Connect App ID：`6780516032`
- Bundle ID：`com.taiwanarch.oshfacilities.illustrated`
- ASC 帳號 / 團隊：`jushiung@gmail.com` / `Yu Shiung Jiang`
- 版本目標：`1.1 (2)`
- IAP：`6780516552` / `com.taiwanarch.oshfacilities.illustrated.full`

## 目前事實

- App Store 正式版：`1.0 (1)` / `READY_FOR_SALE`
- 正式版 Build：`VALID`
- IAP：`APPROVED`
- 1.1 原始碼：功能完成
- 1.1 無簽名 App + Unit/UI test targets：編譯成功
- `scripts/verify_1_1_update.sh`：0 failure
- 1.1 截圖：待在既有 iPhone 6.9 與 iPad 13 Simulator 逐台產生
- Xcode Cloud：待連接本 GitHub 來源並完成 Archive
- Fastlane：待上傳 metadata / screenshots，選取有效 Build 後送審
- Review Submission：尚未建立；不得回報已送審

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

## 暫時阻擋

永久規範要求 Xcode / Simulator 重度流程前資料卷至少保留 15 GiB；2026-07-21
檢查時只有約 8.5 GiB。因此尚未啟動 Simulator。Git、文件、Cloud 與 ASC 可先行，
截圖與 UI test 執行需在空間符合規範後進行。
