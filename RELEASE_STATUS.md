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
- 1.1 無簽名 App + Unit/UI test targets：Xcode 27 beta 編譯成功
- 1.1 自動測試：3 個 Unit + 5 個 UI 全數通過，0 failure
- `scripts/verify_1_1_update.sh`：0 failure
- 1.1 中繼資料：已上傳 ASC
- 1.1 截圖：iPhone 6.9 與 iPad 13 各 6 張，live ASC 均為 `COMPLETE`
- Xcode Cloud：首次 Existing App 綁定回 404；ASC 尚未建立 `ciProduct`，依成功案例清除本機錯綁資料後重建
- 1.1 所選 Build：`null`；待 Cloud 產生並選取 build 2
- Fastlane：metadata / screenshots 已完成；待有效 Build 後送審
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

## 當前發行 Gate

功能、測試與截圖 Gate 已通過。下一個 Gate 是讓 Xcode Cloud `ciProduct` 與 App
`6780516032` relationship 正常回傳，再產生 Archive；不得把本機 placeholder manifest
或單純的 upload 成功當成 Cloud／送審完成。
