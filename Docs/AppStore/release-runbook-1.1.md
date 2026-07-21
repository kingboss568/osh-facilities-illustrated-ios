# 1.1 最短發行路徑

## 固定身分

- App ID：`6780516032`
- Bundle ID：`com.taiwanarch.oshfacilities.illustrated`
- ASC 團隊：`Yu Shiung Jiang`
- 登入帳號：`jushiung@gmail.com`
- 版本 / Build：`1.1 (2)`
- IAP：`6780516552`

不得使用 Mai / YALIN 的 Team、Key、Bundle ID 或 Fastlane 環境。

## Gate

1. `./scripts/verify_1_1_update.sh`
2. 無簽名 Release 與 test targets 編譯成功。
3. 既有最新 iPhone 6.9、iPad 13 各自單獨啟動，執行 UI tests 與按鈕巡檢。
4. 產生 6 + 6 張新截圖並逐張檢查，不沿用 1.0 畫面。
5. 公開 privacy / support URL 均回 HTTP 200。
6. GitHub `main` 已推送，工作樹乾淨。

## Xcode Cloud

使用本版本庫 `main` 建立 Archive workflow，Xcode 27 beta / iOS 最新可用環境；
clone 後 `ci_post_clone.sh` 會重跑 1.1 Gate。只有成功的 Archive / App Store
distribution artifact 才能進下一階段。

若 Existing App 確認畫面的名稱與 Bundle ID 正確，但按 Next 回
`API Invalid status code: 404`，先查 `apps/6780516032/ciProduct`。若仍為 null，
代表是 Cloud relationship 問題，不改 Swift code、不提交 placeholder manifest；依永久列管
成功案例用 Xcode 的 `Delete Xcode Cloud Data...` 清除錯綁資料後重新 Get Started，直到
`ciProduct` 與反向 `/app` relationship 都正常。

## Fastlane

環境由未追蹤的 `.env.fastlane` 提供，禁止提交 API 私鑰。

```zsh
set -a
source .env.fastlane
set +a
bundle exec fastlane ios deliver_metadata
bundle exec fastlane ios deliver_screenshots
```

若 Xcode Cloud workflow 已將 Build 上傳 ASC，不重複上傳 IPA。若只取得 IPA artifact，
才執行：

```zsh
IPA_PATH=/absolute/path/to/App.ipa bundle exec fastlane ios deliver_ipa
```

Build 處理完成後，先確認 `VALID`、版本 `1.1` 已選取該 Build、截圖與合規資訊齊全，
最後才執行 `bundle exec fastlane ios submit_review`。

## 完成定義

- App 版本 1.1 有選定的 `VALID` Build。
- iPhone / iPad 截圖都存在於 live ASC。
- IAP 維持 `APPROVED`。
- Review Submission 包含 App 版本，版本狀態為 `WAITING_FOR_REVIEW` 或後續審查狀態。
- `RELEASE_STATUS.md`、永久任務總表與永久樹索引已更新。
