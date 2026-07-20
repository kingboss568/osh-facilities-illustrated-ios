//
//  FullTextHomeView.swift
//  Tab 2 - 條文全文
//

import SwiftUI

struct FullTextHomeView: View {
    @EnvironmentObject var store: ArticleStore
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title block
                        titleBlock
                            .padding(.horizontal, 22)
                            .padding(.top, 56)
                            .padding(.bottom, 20)

                        // Search bar
                        NavigationLink { SearchView() } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(AppTheme.rust)
                                Text("搜尋條文…")
                                    .foregroundStyle(AppTheme.mute)
                                    .font(.system(size: 15))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.rust.opacity(0.4), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 24)

                        // Series sections
                        ForEach([("general", "總則危害", "GENERAL"),
                                 ("machine", "機械車輛", "MACHINERY"),
                                 ("height", "高處通道", "HEIGHT"),
                                 ("hazard", "電氣化學", "HAZARD"),
                                 ("hygiene", "衛生防護", "HYGIENE")], id: \.0) { sid, sTitle, sEn in
                            seriesSection(seriesId: sid, title: sTitle, en: sEn)
                        }

                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("FULL TEXT")
                .font(.system(size: 9, weight: .regular))
                .italic().kerning(3.2)
                .foregroundStyle(AppTheme.mute)
            Text("條文全文")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 6)
        }
    }

    @ViewBuilder
    private func seriesSection(seriesId: String, title: String, en: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text(en)
                    .font(.system(size: 10, weight: .regular))
                    .italic().kerning(3.2)
                    .foregroundStyle(AppTheme.mute)
                Rectangle().fill(AppTheme.line).frame(height: 1)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)

            ForEach(store.chapters(inSeries: seriesId)) { ch in
                NavigationLink { ChapterArticleListView(chapter: ch) } label: {
                    chapterRow(ch, seriesId: seriesId)
                }
                .buttonStyle(.plain)
                Rectangle().fill(AppTheme.line).frame(height: 1).padding(.leading, 86)
            }
        }
    }

    @ViewBuilder
    private func chapterRow(_ ch: Chapter, seriesId: String) -> some View {
        HStack(spacing: 12) {
            // Mini iso icon
            IsoIcon(kind: chIconKind(ch.id), size: 36)
                .padding(.leading, 22)

            // Ch key number (rust accent)
            Text("\(ch.id)")
                .font(.custom("Times New Roman", size: 16))
                .italic()
                .foregroundStyle(AppTheme.rust)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(ch.title_zh)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                Text("\(store.articles(inChapter: ch.id).count) 條")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.mute)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.mute)
                .padding(.trailing, 22)
        }
        .padding(.vertical, 14)
        .background(AppTheme.paper)
    }

    private func chIconKind(_ id: String) -> IsoIconKind {
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
}

// MARK: - Chapter article list (unchanged logic, updated style)

struct ChapterArticleListView: View {
    let chapter: Chapter
    @EnvironmentObject var store: ArticleStore

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            List(store.articles(inChapter: chapter.id)) { a in
                NavigationLink { ArticleTextView(article: a) } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(a.article_no)
                            .font(.custom("Times New Roman", size: 11)).italic()
                            .foregroundStyle(AppTheme.color(for: a.seriesId))
                        Text(a.title_zh)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                        Text(a.summary)
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.mute)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(AppTheme.paper)
                .listRowSeparatorTint(AppTheme.line)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Ch\(chapter.id) \(chapter.title_zh)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Article text detail (style update only)

struct ArticleTextView: View {
    let article: Article
    /// 從呼叫端直接傳入存取狀態時使用（例如常用條文已由群組邏輯判定免費）；
    /// nil = 預設走 IAPManager.canAccessIllustration(for:)
    var illustrationAccessOverride: Bool? = nil
    @AppStorage("textSize") private var textSize: Double = 17
    @EnvironmentObject var bookmarks: BookmarkStore
    @EnvironmentObject var iap: IAPManager

    var body: some View {
        let illustrationFree = illustrationAccessOverride ?? iap.canAccessIllustration(for: article)
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.article_no)
                        .font(.custom("Times New Roman", size: 14)).italic()
                        .foregroundStyle(AppTheme.rust)
                    Text(article.title_zh)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Rectangle().fill(AppTheme.line).frame(height: 1)
                    Text(article.summary)
                        .font(.system(size: textSize))
                        .lineSpacing(6)
                        .foregroundStyle(AppTheme.primary)
                    Divider().background(AppTheme.line)
                    NavigationLink {
                        if illustrationFree { ArticleDetailView(article: article) }
                        else { PaywallView() }
                    } label: {
                        HStack {
                            Image(systemName: illustrationFree ? "photo" : "lock.fill")
                            Text("看圖解")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(illustrationFree ? AppTheme.rust : AppTheme.mute.opacity(0.3),
                                    in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(illustrationFree ? .white : AppTheme.mute)
                    }
                }
                .padding(22)
                Spacer().frame(height: 60)
            }
        }
        .navigationTitle(article.id)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("小字 (14pt)") { textSize = 14 }
                    Button("中字 (17pt)") { textSize = 17 }
                    Button("大字 (20pt)") { textSize = 20 }
                    Button("特大 (24pt)") { textSize = 24 }
                } label: { Image(systemName: "textformat.size") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    _ = bookmarks.toggle(article.id, isUnlocked: iap.isUnlocked)
                } label: {
                    Image(systemName: bookmarks.contains(article.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(AppTheme.rust)
                }
            }
        }
    }
}
