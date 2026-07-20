//
//  OnboardingView.swift
//  職業安全衛生設施規則全圖解
//
//  3-page intro shown on first launch.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    var body: some View {
        VStack {
            TabView(selection: $page) {
                isoHousePage(
                    title: "250 張職安圖解",
                    body: "把機械防護、高處通道、特殊危害與衛生防護整理成一張就懂的職安圖說。"
                ).tag(0)

                onboardPage(
                    icon: "checklist",
                    title: "題庫測驗",
                    body: "用職安情境題複習常見法規風險，答題後回到相關圖解。",
                    color: AppTheme.structSeries
                ).tag(1)

                onboardPage(
                    icon: "lock.shield.fill",
                    title: "一次買斷 永久使用",
                    body: "免費試用前 20 張圖解與 20 題測驗；NT$390 一次買斷全功能，沒有訂閱、沒有廣告。",
                    color: AppTheme.primary
                ).tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(AppTheme.paperBG.ignoresSafeArea())

            Button(page < 2 ? "下一步" : "開始使用") {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    onFinish()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
            .padding()
        }
    }

    private func onboardPage(icon: String, title: String, body: String, color: Color) -> some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: icon).font(.system(size: 84)).foregroundStyle(color)
            Text(title).font(.largeTitle.bold())
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var safetyMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(AppTheme.primary.opacity(0.08))
                .frame(width: 210, height: 210)
            Circle()
                .stroke(AppTheme.gold.opacity(0.7), lineWidth: 7)
                .frame(width: 142, height: 142)
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 86, weight: .bold))
                .foregroundStyle(AppTheme.primary)
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AppTheme.resourceBlue)
                .offset(x: 62, y: -58)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.rust)
                .offset(x: -64, y: 62)
        }
        .frame(width: 220, height: 220)
    }

    private func isoHousePage(title: String, body: String) -> some View {
        VStack(spacing: 22) {
            Spacer()
            safetyMark
            Text(title).font(.largeTitle.bold())
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
