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
                case 2: FireCommonClausesView()
                case 3: CalculatorsHomeView()
                case 4: RegulatoryResourcesView()
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
        return min(max(tab, 0), 4)
    }
}

// MARK: - Floating Tab Bar

private struct FloatingTabBar: View {
    @Binding var selected: Int

    private let tabs: [(label: String, icon: TabIconShape.TabIcon)] = [
        ("圖解", .illust),
        ("條文", .fulltext),
        ("常用", .common),
        ("工具", .calc),
        ("資源", .resource),
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
    private func tabItem(label: String, icon: TabIconShape.TabIcon, active: Bool) -> some View {
        let color: Color = active ? AppTheme.rust : AppTheme.mute
        VStack(spacing: 3) {
            ZStack {
                if active {
                    // Active indicator underline
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(AppTheme.rust)
                        .frame(width: 20, height: 3)
                        .offset(y: -14)
                }
                TabIconShape(kind: icon)
                    .stroke(color, style: StrokeStyle(lineWidth: active ? 1.8 : 1.7,
                                                      lineCap: .round, lineJoin: .round))
                    .frame(width: 23, height: 23)
                    // Filled version for active state
                    .background(
                        Group {
                            if active {
                                tabFill(icon: icon)
                            }
                        }
                    )
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    // Active filled layer for certain icons
    @ViewBuilder
    private func tabFill(icon: TabIconShape.TabIcon) -> some View {
        switch icon {
        case .illust:
            // diamond filled
            TabIconShape(kind: .illust)
                .fill(AppTheme.rust)
                .frame(width: 24, height: 24)
        case .fulltext:
            TabIconShape(kind: .fulltext)
                .fill(AppTheme.rust)
                .frame(width: 24, height: 24)
        case .common:
            TabIconShape(kind: .common)
                .fill(AppTheme.rust)
                .frame(width: 24, height: 24)
        case .calc:
            TabIconShape(kind: .calc)
                .fill(AppTheme.rust)
                .frame(width: 24, height: 24)
        case .resource:
            TabIconShape(kind: .resource)
                .fill(AppTheme.rust)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ArticleStore.preview)
        .environmentObject(BookmarkStore())
        .environmentObject(IAPManager())
}
