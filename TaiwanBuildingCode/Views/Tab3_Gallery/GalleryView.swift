import SwiftUI

struct GalleryView: View {
    var body: some View {
        NavigationStack {
            AllGalleryView()
        }
    }
}

struct AllGalleryView: View {
    var body: some View {
        GalleryContentView(seriesId: nil, title: "圖卡快覽")
    }
}

struct SeriesGalleryView: View {
    let seriesId: String
    let title: String

    var body: some View {
        GalleryContentView(seriesId: seriesId, title: title)
    }
}

private struct GalleryContentView: View {
    let seriesId: String?
    let title: String

    @EnvironmentObject private var store: ArticleStore
    @EnvironmentObject private var iap: IAPManager
    @State private var query = ""
    @State private var selectedSeries = "全部"

    private let filters: [(id: String, title: String)] = [
        ("全部", "全部"),
        ("general", "總則危害"),
        ("machine", "機械車輛"),
        ("height", "高處通道"),
        ("hazard", "電氣化學"),
        ("hygiene", "衛生防護")
    ]

    private var visibleArticles: [Article] {
        let base: [Article]
        if let seriesId {
            base = store.articles(inSeries: seriesId)
        } else if selectedSeries == "全部" {
            base = store.allArticles
        } else {
            base = store.articles(inSeries: selectedSeries)
        }

        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return base }
        let resultIDs = Set(store.search(needle).map(\.id))
        return base.filter { resultIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    galleryHeader
                    searchField
                    if seriesId == nil {
                        filterBar
                    }
                    resultHeader
                    if visibleArticles.isEmpty {
                        ContentUnavailableView.search(text: query)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 48)
                    } else {
                        PinterestArticleGrid(articles: visibleArticles)
                    }
                    Spacer().frame(height: 96)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !iap.isUnlocked {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        PaywallView()
                    } label: {
                        Label("Pro / 解鎖完整圖解", systemImage: "crown.fill")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(AppTheme.rust)
                    }
                    .accessibilityIdentifier("gallery-pro-unlock")
                }
            }
        }
    }

    private var galleryHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("PINTEREST STYLE GALLERY")
                    .font(.system(size: 9, weight: .bold))
                    .kerning(2)
                    .foregroundStyle(AppTheme.mute)
                Text(seriesId == nil ? "雙欄圖卡快覽" : title)
                    .font(.system(size: 27, weight: .heavy, design: .serif))
                    .foregroundStyle(AppTheme.primary)
                Text("兩列並排・250 張本機圖解・可持續上下滑動")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.mute)
            }
            Spacer()
            Image(systemName: "rectangle.grid.2x2.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.rust)
                .frame(width: 50, height: 50)
                .background(AppTheme.rust.opacity(0.10), in: RoundedRectangle(cornerRadius: 15))
        }
        .padding(15)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.line))
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.primary)
            TextField("搜尋條號、標題、危害或設備", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("gallery-search-field")
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.mute)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清除圖卡搜尋")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line))
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.id) { filter in
                    Button {
                        withAnimation(.snappy(duration: 0.24)) {
                            selectedSeries = filter.id
                        }
                    } label: {
                        Text(filter.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selectedSeries == filter.id ? .white : AppTheme.primary)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(
                                selectedSeries == filter.id
                                    ? AppTheme.color(for: filter.id)
                                    : .white,
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(AppTheme.line))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var resultHeader: some View {
        HStack {
            Text(query.isEmpty ? "圖卡索引" : "搜尋結果")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Spacer()
            Text("\(visibleArticles.count) 張")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.mute)
                .accessibilityIdentifier("gallery-result-count")
        }
    }
}

private struct PinterestArticleGrid: View {
    let articles: [Article]

    private var leftColumn: [Article] {
        articles.enumerated().compactMap { $0.offset.isMultiple(of: 2) ? $0.element : nil }
    }

    private var rightColumn: [Article] {
        articles.enumerated().compactMap { !$0.offset.isMultiple(of: 2) ? $0.element : nil }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            LazyVStack(spacing: 10) {
                ForEach(leftColumn) { article in
                    PinterestArticleLink(article: article)
                }
            }
            LazyVStack(spacing: 10) {
                ForEach(rightColumn) { article in
                    PinterestArticleLink(article: article)
                }
            }
        }
    }
}

private struct PinterestArticleLink: View {
    let article: Article
    @EnvironmentObject private var store: ArticleStore
    @EnvironmentObject private var iap: IAPManager

    private var canAccess: Bool {
        iap.canAccess(article: article, allArticles: store.allArticles)
    }

    var body: some View {
        NavigationLink {
            if canAccess {
                ArticleDetailView(article: article)
            } else {
                PaywallView()
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ResourceJPEG(name: article.imageAssetName)
                        .aspectRatio(3.0 / 4.0, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    if !canAccess {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.48)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.35), in: Circle())
                            .padding(7)
                    }
                }
                Text(article.article_no)
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(AppTheme.rust)
                Text(article.title_zh)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                Text(article.summary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
                    .multilineTextAlignment(.leading)
                    .lineLimit(article.serial.isMultiple(of: 3) ? 3 : 2)
            }
            .padding(9)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line))
            .shadow(color: AppTheme.primary.opacity(0.05), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("gallery-card-\(article.id)")
    }
}
