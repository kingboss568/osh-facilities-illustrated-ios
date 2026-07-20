//
//  RegulatoryResourcesView.swift
//  職業安全衛生設施規則全圖解
//
//  Occupational safety facilities law lookup and official resource hub.
//

import SwiftUI

struct RegulatoryResourcesView: View {
    @EnvironmentObject private var store: ArticleStore
    @State private var query = ""
    @State private var selectedCategory: RegulatoryResource.Category?

    private let quickTerms = ["職業安全", "機械", "高處作業", "防護", "化學品", "通道"]

    private var localMatches: [Article] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }
        return Array(store.search(normalized).prefix(6))
    }

    private var resourceMatches: [RegulatoryResource] {
        RegulatoryResource.filtered(query: query, category: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        searchPanel
                        localSearchSection
                        resourceSection
                        disclaimer
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 54)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REGULATORY DESK")
                .font(.system(size: 9, weight: .medium))
                .italic()
                .kerning(3)
                .foregroundStyle(AppTheme.mute)
            Text("法規檢索")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            HStack(spacing: 10) {
                MetricPill(value: "\(store.allArticles.count)", label: "本機條文")
                MetricPill(value: "\(RegulatoryResource.official.count)", label: "官方連結")
            }
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private var searchPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.resourceBlue)
                TextField("輸入條號、關鍵字或網站名稱", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 16, weight: .semibold))
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.mute.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.blueprint.opacity(0.18), lineWidth: 1))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickTerms, id: \.self) { term in
                        Button { query = term } label: {
                            Text(term)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(query == term ? .white : AppTheme.resourceBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(query == term ? AppTheme.resourceBlue : AppTheme.sky.opacity(0.22),
                                            in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.blueprint.opacity(0.13), lineWidth: 1))
    }

    @ViewBuilder
    private var localSearchSection: some View {
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "本機條文", subtitle: localMatches.isEmpty ? "沒有相符條文" : "\(localMatches.count) 筆快速結果")
                if localMatches.isEmpty {
                    EmptyResultRow(text: "可改用條號、章節名稱或摘要關鍵字搜尋。")
                } else {
                    VStack(spacing: 10) {
                        ForEach(localMatches) { article in
                            NavigationLink { ArticleTextView(article: article) } label: {
                                LocalArticleResultRow(article: article)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var resourceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "常用職安法規網站", subtitle: "\(resourceMatches.count) 個法規入口")
            categoryFilter

            if resourceMatches.isEmpty {
                EmptyResultRow(text: "沒有符合目前條件的網站連結。")
            } else {
                VStack(spacing: 10) {
                    ForEach(resourceMatches) { resource in
                        Link(destination: resource.url) {
                            ResourceLinkRow(resource: resource)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "全部", active: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(RegulatoryResource.Category.allCases) { category in
                    CategoryChip(title: category.rawValue, active: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(AppTheme.leaf)
            Text("本 App 提供職安設施規則圖解、測驗與速查輔助；正式申請、審查、施工與使用安全責任仍應以主管機關最新公告、核准圖說、現場條件與專業人士判斷為準。")
                .font(.system(size: 12, weight: .medium))
                .lineSpacing(3)
                .foregroundStyle(AppTheme.mute)
        }
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MetricPill: View {
    let value: String
    let label: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.custom("Times New Roman", size: 18))
                .italic()
                .foregroundStyle(AppTheme.resourceBlue)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.mute)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.78), in: Capsule())
    }
}

private struct SectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Spacer()
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.mute)
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(active ? .white : AppTheme.primary)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(active ? AppTheme.resourceBlue : .white, in: Capsule())
                .overlay(Capsule().stroke(AppTheme.line, lineWidth: active ? 0 : 1))
        }
        .buttonStyle(.plain)
    }
}

private struct LocalArticleResultRow: View {
    let article: Article

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.article_no)
                    .font(.custom("Times New Roman", size: 12))
                    .italic()
                    .foregroundStyle(AppTheme.color(for: article.seriesId))
                Text(article.title_zh)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(1)
                Text(article.summary)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.mute.opacity(0.7))
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct ResourceLinkRow: View {
    let resource: RegulatoryResource

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(categoryColor.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: resource.symbolName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(categoryColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(resource.title)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(1)
                    Text(resource.category.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(categoryColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(categoryColor.opacity(0.12), in: Capsule())
                }
                Text(resource.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(2)
                Text(resource.url.host() ?? resource.url.absoluteString)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.resourceBlue.opacity(0.75))
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "arrow.up.forward")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(AppTheme.mute.opacity(0.75))
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }

    private var categoryColor: Color {
        switch resource.category {
        case .law: return AppTheme.rust
        case .agency: return AppTheme.resourceBlue
        case .guide: return AppTheme.leaf
        case .system: return AppTheme.gold
        }
    }
}

private struct EmptyResultRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "tray")
                .foregroundStyle(AppTheme.mute)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RegulatoryResourcesView()
        .environmentObject(ArticleStore.preview)
        .environmentObject(BookmarkStore())
        .environmentObject(IAPManager())
}
