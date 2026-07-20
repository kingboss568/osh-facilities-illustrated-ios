//
//  ContentView.swift
//  職業安全衛生設施規則全圖解
//
//  Root view — custom floating tab bar per _bootstrap.html design system.
//  White pill · rust active state · custom isometric SVG icons.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var iapManager: IAPManager
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding = false
    @State private var selectedTab = ScreenshotLaunchOptions.initialTab
    @State private var showingScreenshotPaywall = ScreenshotLaunchOptions.showPaywall

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Page content ──────────────────────────────────────────────
            Group {
                switch selectedTab {
                case 0: IllustrationsHomeView()
                case 1: FullTextHomeView()
                case 2: GalleryView()
                case 3: FireCommonClausesView()
                case 4: CalculatorsHomeView()
                case 5: RegulatoryResourcesView()
                default: IllustrationsHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Floating tab bar ─────────────────────────────────────────
            FloatingTabBar(selected: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(AppTheme.paper.ignoresSafeArea())
        .sheet(isPresented: .init(
            get: { !hasShownOnboarding && !ScreenshotLaunchOptions.isScreenshotMode },
            set: { hasShownOnboarding = !$0 }
        )) {
            OnboardingView { hasShownOnboarding = true }
        }
        .sheet(isPresented: $showingScreenshotPaywall) {
            PaywallView()
        }
    }
}

private enum ScreenshotLaunchOptions {
    private static let arguments = ProcessInfo.processInfo.arguments

    static var isScreenshotMode: Bool {
        arguments.contains("--screenshot")
    }

    static var showPaywall: Bool {
        arguments.contains("--screenshot-paywall")
    }

    static var initialTab: Int {
        guard let index = arguments.firstIndex(of: "--screenshot-tab"),
              arguments.indices.contains(index + 1),
              let tab = Int(arguments[index + 1]) else {
            return 0
        }
        return min(max(tab, 0), 5)
    }
}

// MARK: - Floating Tab Bar

private struct FloatingTabBar: View {
    @Binding var selected: Int

    private let tabs: [(label: String, icon: String)] = [
        ("圖解", "square.stack.3d.up.fill"),
        ("條文", "doc.text.fill"),
        ("快覽", "rectangle.grid.2x2.fill"),
        ("常用", "bookmark.fill"),
        ("工具", "wrench.and.screwdriver.fill"),
        ("資源", "books.vertical.fill"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                        selected = idx
                    }
                } label: {
                    tabItem(label: tab.label, icon: tab.icon, active: selected == idx)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("tab-\(idx)")
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 64)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color(red: 0.314, green: 0.235, blue: 0.118).opacity(0.18),
                radius: 20, x: 0, y: 6)
        .padding(.horizontal, 14)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private func tabItem(label: String, icon: String, active: Bool) -> some View {
        let color: Color = active ? AppTheme.rust : AppTheme.mute
        VStack(spacing: 4) {
            ZStack {
                if active {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(AppTheme.rust)
                        .frame(width: 18, height: 3)
                        .offset(y: -15)
                }
                Image(systemName: icon)
                    .font(.system(size: 18, weight: active ? .heavy : .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
                    .frame(width: 22, height: 22)
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ArticleStore.preview)
        .environmentObject(BookmarkStore())
        .environmentObject(IAPManager())
}
