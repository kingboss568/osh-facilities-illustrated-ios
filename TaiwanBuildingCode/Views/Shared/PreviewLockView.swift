//
//  PreviewLockView.swift
//  職業安全衛生設施規則全圖解
//
//  Reusable lock card shown when free-tier user hits a paid item.
//

import SwiftUI

struct PreviewLockCard: View {
    let title: String
    let subtitle: String
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primary)
            Text(title).font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showPaywall = true
            } label: {
                Text("立即解鎖 \(Constants.fallbackPriceText)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(AppTheme.cardBG, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    PreviewLockCard(title: "Pro / Pro / Pro / Pro / Pro / Pro / Pro / Pro / Pro / Pro / 解鎖完整圖解", subtitle: "免費版可瀏覽前 20 張，購買後解鎖全部 250 張。")
        .environmentObject(IAPManager())
}
