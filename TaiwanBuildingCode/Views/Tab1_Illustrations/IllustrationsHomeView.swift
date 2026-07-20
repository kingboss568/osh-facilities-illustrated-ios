//
//  IllustrationsHomeView.swift
//  Tab 1 root — 職安設施規則圖解分類
//  職安申請大卡片 → 章節 → 縮圖網格 → 圖解詳情
//

import SwiftUI

// MARK: - Home

struct IllustrationsHomeView: View {
    @EnvironmentObject var store: ArticleStore
    @EnvironmentObject var iap: IAPManager

    private let series: [(id: String, title: String, en: String,
                          range: String, icon: IsoIconKind)] = [
        ("general", "總則危害", "GENERAL", "Ch 01", .boxBasic),
        ("machine", "機械車輛", "MACHINERY", "Ch 02", .gear),
        ("height", "高處通道", "HEIGHT", "Ch 03", .stairs),
        ("hazard", "電氣化學", "HAZARD", "Ch 04", .favFire),
        ("hygiene", "衛生防護", "HYGIENE", "Ch 05", .featText),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        headerBar
                            .padding(.horizontal, 22)
                            .padding(.top, 14)

                        HomeHeroCard()
                            .padding(.horizontal, 22)

                        PremiumSearchLink()
                            .padding(.horizontal, 22)

                        statsBar
                            .padding(.horizontal, 22)

                        categoryDeck
                            .padding(.horizontal, 22)

                        priorityFocus
                            .padding(.horizontal, 22)

                        if !iap.isUnlocked {
                            UnlockPromoCard()
                                .padding(.horizontal, 22)
                        }

                        featuredStrip

                        quickActions
                            .padding(.horizontal, 22)

                        Spacer().frame(height: 100)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SearchView() } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.primary)
                    }
                }
                if !iap.isUnlocked {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink { PaywallView() } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill").font(.caption)
                                Text("Pro").font(.callout.bold())
                            }
                            .foregroundStyle(AppTheme.rust)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("職安設施 Pro")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.rust)
                Text("職業安全衛生設施規則全圖解")
                    .font(.system(size: 32, weight: .heavy, design: .serif))
                    .foregroundStyle(AppTheme.primary)
                    .minimumScaleFactor(0.76)
                    .lineLimit(1)
            }
            Spacer()
            NavigationLink { PaywallView() } label: {
                Image(systemName: iap.isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.82), in: Circle())
                    .overlay(Circle().stroke(AppTheme.line, lineWidth: 1))
            }
            .accessibilityLabel(iap.isUnlocked ? "已解鎖完整版" : "Pro 解鎖完整圖解")
        }
    }

    private var statsBar: some View {
        HStack(spacing: 0) {
            statCell(value: "\(max(store.allArticles.count, 250))", unit: "張", label: "圖解")
            divider
            statCell(value: "5", unit: "大", label: "主題")
            divider
            statCell(value: "20", unit: "張", label: "免費預覽")
            divider
            statCell(value: "20", unit: "項", label: "工具")
        }
        .padding(.vertical, 10)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
        .shadow(color: AppTheme.primary.opacity(0.04), radius: 6, y: 3)
    }

    private var divider: some View {
        Rectangle().fill(AppTheme.line).frame(width: 1, height: 34)
    }

    private func statCell(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .heavy, design: .serif))
                    .foregroundStyle(AppTheme.rust)
                Text(unit)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.mute)
            }
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.mute)
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("五大分類")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Spacer()
                Text("250 張完整索引")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.mute)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 152), spacing: 10)], spacing: 10) {
                ForEach(series, id: \.id) { s in
                    let count = store.articles(inSeries: s.id).count
                    NavigationLink {
                        SeriesChapterListView(seriesId: s.id, seriesTitle: s.title)
                    } label: {
                        SeriesPillCard(seriesId: s.id,
                                       title: s.title,
                                       range: s.range,
                                       icon: s.icon,
                                       count: count)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var priorityFocus: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            focusCard(
                title: "職安許可檢核",
                subtitle: "最低標準、設備、措施",
                count: store.articles(inSeries: "general").count,
                seriesId: "general",
                icon: .boxBasic
            )
            focusCard(
                title: "機械車輛與高處",
                subtitle: "防護、通道、防墜",
                count: store.articles(inSeries: "machine").count + store.articles(inSeries: "height").count,
                seriesId: "height",
                icon: .favFire
            )
        }
    }

    private func focusCard(title: String, subtitle: String, count: Int, seriesId: String, icon: IsoIconKind) -> some View {
        NavigationLink {
            SeriesChapterListView(seriesId: seriesId, seriesTitle: title)
        } label: {
            HStack(spacing: 10) {
                IsoIcon(kind: icon, size: 38)
                    .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.mute)
                        .lineLimit(1)
                    Text("\(count) 張專題圖解")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(AppTheme.color(for: seriesId))
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 74)
            .background(AppTheme.color(for: seriesId).opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppTheme.color(for: seriesId).opacity(0.28), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var featuredArticles: [Article] {
        let ids = ["01-001", "01-012", "02-006", "03-010", "04-016", "05-006", "05-024", "05-039"]
        let picked = ids.compactMap { store.article(by: $0) }
        return picked.isEmpty ? Array(store.allArticles.prefix(6)) : picked
    }

    private var featuredStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("精選圖解")
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Spacer()
                NavigationLink {
                    SeriesChapterListView(seriesId: "general", seriesTitle: "職業安全")
                } label: {
                    HStack(spacing: 4) {
                        Text("全部")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.rust)
                }
            }
            .padding(.horizontal, 22)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featuredArticles) { article in
                        let canAccess = iap.canAccess(article: article, allArticles: store.allArticles)
                        NavigationLink {
                            if canAccess { ArticleDetailView(article: article) }
                            else { PaywallView() }
                        } label: {
                            FeaturedArticleCard(article: article, locked: !canAccess)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 14)], spacing: 14) {
            NavigationLink { SearchView() } label: {
                QuickActionCard(icon: "doc.text.magnifyingglass",
                                title: "條文查詢",
                                subtitle: "關鍵字、條號、圖解索引")
            }
            NavigationLink { CalculatorsHomeView() } label: {
                QuickActionCard(icon: "checklist.checked",
                                title: "Pro 工具",
                                subtitle: "送件、尺寸、公安檢核")
            }
            NavigationLink { FireCommonClausesView() } label: {
                QuickActionCard(icon: "folder",
                                title: "常用懶人包",
                                subtitle: "高頻條文與現場風險")
            }
            NavigationLink { RegulatoryResourcesView() } label: {
                QuickActionCard(icon: "books.vertical",
                                title: "法規資源",
                                subtitle: "官方連結與查詢入口")
            }
        }
        .buttonStyle(.plain)
    }
}

private struct HomeHeroCard: View {
    var body: some View {
        Image("HomeHero")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(AppTheme.line.opacity(0.9), lineWidth: 1))
            .shadow(color: AppTheme.primary.opacity(0.18), radius: 22, y: 12)
    }
}

private struct UnlockPromoCard: View {
    var body: some View {
        NavigationLink { PaywallView() } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.rust.opacity(0.14))
                        .frame(width: 52, height: 52)
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.rust)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Pro / 解鎖完整圖解")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("一次買斷・250 張圖解・工具題庫完整解鎖")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.78))
                }
                Spacer()
                Text("Pro 解鎖")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(.white, in: Capsule())
            }
            .padding(16)
            .background(
                LinearGradient(colors: [AppTheme.primary, AppTheme.primary.opacity(0.82)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(0.25), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct PremiumSearchLink: View {
    var body: some View {
        NavigationLink { SearchView() } label: {
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
                Text("搜尋條文、關鍵字、機械防護、高處作業、化學品...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.rust)
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 52)
            .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
            .shadow(color: AppTheme.primary.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("搜尋條文與關鍵字")
    }
}

private struct SeriesPillCard: View {
    let seriesId: String
    let title: String
    let range: String
    let icon: IsoIconKind
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            IsoIcon(kind: icon, size: 46)
                .frame(width: 50, height: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Text(range)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.mute)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(count)")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundStyle(AppTheme.color(for: seriesId))
                    Text("張")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.mute)
                }
                Spacer()
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppTheme.color(for: seriesId))
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 118)
        .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.color(for: seriesId))
                .frame(width: 5)
        }
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
        .shadow(color: AppTheme.primary.opacity(0.05), radius: 8, y: 4)
    }
}

private struct FeaturedArticleCard: View {
    let article: Article
    let locked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ResourceJPEG(name: article.imageAssetName)
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 132, height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    if locked {
                        Color.black.opacity(0.32)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            Text(article.article_no)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(1)
            Text(article.title_zh)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 152, height: 206)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(AppTheme.primary)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
            }
            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 92)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
    }
}

// MARK: - Big series card

private struct BigSeriesCard: View {
    let seriesId: String
    let title: String
    let en: String
    let range: String
    let icon: IsoIconKind
    let count: Int

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(en)
                    .font(.custom("Times New Roman", size: 10))
                    .italic().kerning(1.8)
                    .foregroundStyle(AppTheme.mute)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(AppTheme.line, in: Capsule())
                Text(title)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(range)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.mute)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(count)")
                        .font(.custom("Times New Roman", size: 32))
                        .italic()
                        .foregroundStyle(AppTheme.color(for: seriesId))
                    Text("張")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                }
            }
            .padding(.leading, 20).padding(.vertical, 18)
            Spacer()
            IsoIcon(kind: icon, size: 110)
                .padding(.trailing, 12).padding(.vertical, 10)
        }
        .frame(minHeight: 130)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
    }
}

// MARK: - Chapter list inside a series

struct SeriesChapterListView: View {
    let seriesId: String
    let seriesTitle: String
    @EnvironmentObject var store: ArticleStore

    private func iconKind(_ id: String) -> IsoIconKind {
        switch id {
        case "01": return .boxBasic
        case "02": return .favDesign
        case "03": return .boxBand
        case "04": return .columnSmall
        case "05": return .featText
        case "06": return .featStar
        default: return .gear
        }
    }

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            List(store.chapters(inSeries: seriesId)) { ch in
                NavigationLink { ChapterGridView(chapter: ch) } label: {
                    HStack(spacing: 12) {
                        IsoIcon(kind: iconKind(ch.id), size: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ch \(ch.id)")
                                .font(.custom("Times New Roman", size: 11))
                                .italic().kerning(1.8)
                                .foregroundStyle(AppTheme.rust)
                            Text(ch.title_zh)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppTheme.primary)
                            Text(ch.intro)
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.mute)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("\(store.articles(inChapter: ch.id).count)")
                            .font(.custom("Times New Roman", size: 14))
                            .italic().foregroundStyle(AppTheme.mute)
                    }
                    .padding(.vertical, 10)
                }
                .listRowBackground(AppTheme.paper)
                .listRowSeparatorTint(AppTheme.line)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(seriesTitle)
    }
}

// MARK: - Thumbnail grid for one chapter

struct ChapterGridView: View {
    let chapter: Chapter
    @EnvironmentObject var store: ArticleStore
    @EnvironmentObject var iap: IAPManager

    private let cols = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(store.articles(inChapter: chapter.id)) { article in
                        let canAccess = iap.canAccess(article: article,
                                                       allArticles: store.allArticles)
                        NavigationLink {
                            if canAccess { ArticleDetailView(article: article) }
                            else { PaywallView() }
                        } label: {
                            ThumbnailCard(article: article, locked: !canAccess)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                Spacer().frame(height: 80)
            }
        }
        .navigationTitle("Ch\(chapter.id) \(chapter.title_zh)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThumbnailCard: View {
    let article: Article
    let locked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                ResourceJPEG(name: article.imageAssetName)
                    .aspectRatio(3/4, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        if locked {
                            Color.black.opacity(0.42)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.white).font(.title2)
                        }
                    }
                Text(article.id)
                    .font(.custom("Times New Roman", size: 10)).italic()
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.thinMaterial, in: Capsule())
                    .padding(6)
            }
            Text(article.title_zh)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(2)
        }
        .padding(10)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }
}
