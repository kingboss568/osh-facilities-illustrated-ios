//
//  PaywallView.swift
//  職業安全衛生設施規則全圖解
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var iap: IAPManager
    @Environment(\.dismiss) var dismiss
    @State private var showingErrorAlert = false

    private let features: [(serial: String, text: String, icon: IsoIconKind)] = [
        ("01", "250 張職安設施規則圖解", .featIllust),
        ("02", "20 張免費預覽，Pro 解鎖完整圖解", .featText),
        ("03", "100 題職安設施測驗與解析", .featCalc),
        ("04", "20 項現場檢核工具", .featStar),
        ("05", "官方法規連結與條文速查", .featCloud),
        ("06", "Apple ID 跨裝置恢復購買", .featCloud),
        ("07", "一次買斷，無廣告、無訂閱", .featNoAd),
    ]

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    // ── Hero: house + lock ───────────────────────────────
                    IsoIcon(kind: .lockHero, size: 140)
                        .padding(.top, 48)
                        .padding(.bottom, 14)

                    // Stamp
                    Text("UNLOCK FULL ACCESS")
                        .font(.system(size: 9)).italic().kerning(3.2)
                        .foregroundStyle(AppTheme.mute)
                        .padding(.bottom, 8)

                    // Title
                    Text("Pro / 解鎖完整圖解")
                        .font(.system(size: 28, weight: .heavy))
                        .kerning(0.6)
                        .foregroundStyle(AppTheme.primary)

                    Text("NT$390 一次買斷・解鎖 250 張")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.mute)
                        .padding(.bottom, 28)

                    // ── Feature list ─────────────────────────────────────
                    VStack(spacing: 0) {
                        ForEach(features, id: \.serial) { f in
                            featureRow(f)
                            if f.serial != "07" {
                                Rectangle().fill(AppTheme.line).frame(height: 1)
                                    .padding(.leading, 62)
                            }
                        }
                    }
                    .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)

                    // ── CTA ───────────────────────────────────────────────
                    // Reviewer must always see a tappable IAP CTA. If StoreKit is
                    // still resolving the product, tapping this button retries first.
                    Button {
                        Task { await iap.purchase() }
                    } label: {
                        VStack(spacing: 3) {
                            if iap.isLoadingProduct || iap.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("立即解鎖")
                                    .font(.system(size: 14, weight: .heavy))
                                    .kerning(1.8)
                            }
                            Text(iap.purchaseButtonPriceText + "・一次買斷")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.rust, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                    }
                    .disabled(iap.isPurchasing || iap.isLoadingProduct)
                    .padding(.horizontal, 22)

                    if iap.product == nil && !iap.isLoadingProduct {
                        Button {
                            Task { await iap.loadProduct() }
                        } label: {
                            Text("重新載入內購商品")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppTheme.mute)
                        }
                        .padding(.top, 8)
                    }

                    // Restore
                    Button("已購買？恢復購買") {
                        Task { await iap.restore() }
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.mute)
                    .padding(.top, 12)

                    // Legal: EULA + Privacy
                    HStack(spacing: 4) {
                        Link("使用條款", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        Text("・")
                        Link("隱私政策", destination: URL(string: "https://kingboss568.github.io/osh-facilities-law-support/privacy.html")!)
                        Text("・")
                        Link("支援", destination: URL(string: "https://kingboss568.github.io/osh-facilities-law-support/support.html")!)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.mute)
                    .padding(.top, 8)

                    Text("購買後支援所有 iPhone / iPad，可在 Apple ID 任意裝置使用。")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.mute)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                // iPad 限寬：iPad Air 11" / 13" 上不會過寬
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .task { await iap.refreshEntitlements() }
        .onChange(of: iap.isUnlocked) { _, newValue in
            if newValue { dismiss() }
        }
        // 購買錯誤 alert — 用 State 綁定才能正確關閉（不用 .constant）
        .onChange(of: iap.purchaseError) { _, newVal in
            if newVal != nil { showingErrorAlert = true }
        }
        .alert("提示", isPresented: $showingErrorAlert) {
            Button("好") { iap.clearPurchaseError() }
        } message: {
            Text(iap.purchaseError ?? "")
        }
    }

    @ViewBuilder
    private func featureRow(_ f: (serial: String, text: String, icon: IsoIconKind)) -> some View {
        HStack(spacing: 10) {
            // Serial number
            Text(f.serial)
                .font(.custom("Times New Roman", size: 11))
                .italic().kerning(0.5)
                .foregroundStyle(AppTheme.mute)
                .frame(width: 24)
            // Mini iso icon
            IsoIcon(kind: f.icon, size: 28)
            // Text
            Text(f.text)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.primary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

#Preview {
    PaywallView().environmentObject(IAPManager())
}
