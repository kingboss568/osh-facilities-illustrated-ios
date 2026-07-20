//
//  CommonClausesView.swift
//  職業安全常用條文懶人包
//

import SwiftUI

struct CommonClauseGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let articleIds: [String]
    let isoIcon: IsoIconKind
}

struct CommonClausesView: View {
    @EnvironmentObject var store: ArticleStore

    private static let groups: [CommonClauseGroup] = [
        .init(id: "general", title: "總則危害", articleIds: ["01-001", "01-002", "01-003", "01-004", "01-005"], isoIcon: .favDesign),
        .init(id: "machine", title: "機械車輛", articleIds: ["02-001", "02-002", "02-003", "02-004", "02-005"], isoIcon: .boxBasic),
        .init(id: "height", title: "高處通道", articleIds: ["03-001", "03-002", "03-003", "03-004", "03-005"], isoIcon: .favAccess),
        .init(id: "hazard", title: "電氣化學", articleIds: ["04-001", "04-002", "04-003", "04-004", "04-005"], isoIcon: .favStruct),
        .init(id: "hygiene", title: "衛生防護", articleIds: ["05-001", "05-002", "05-003", "05-004", "05-005"], isoIcon: .favGreen),
    ]

    private let cols = [GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title block
                        VStack(alignment: .leading, spacing: 5) {
                            Text("QUICK REFERENCE")
                                .font(.system(size: 9)).italic().kerning(3.2)
                                .foregroundStyle(AppTheme.mute)
                            Text("常用條文")
                                .font(.system(size: 34, weight: .heavy))
                                .foregroundStyle(AppTheme.primary)
                            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 6)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 56)
                        .padding(.bottom, 24)

                        // 2-col fav grid
                        LazyVGrid(columns: cols, spacing: 10) {
                            ForEach(Array(Self.groups.enumerated()), id: \.element.id) { idx, g in
                                NavigationLink {
                                    CommonClauseGroupView(group: g, groupIndex: idx)
                                } label: {
                                    FavCard(group: g, count: g.articleIds.count)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 22)

                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Fav card (1:1 aspect ratio)

private struct FavCard: View {
    let group: CommonClauseGroup
    let count: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                // Background
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.kraft)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))

                // Iso icon — bottom right
                IsoIcon(kind: group.isoIcon, size: 64)
                    .padding(10)
                    .opacity(0.85)

                // Text — top left
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title)
                        .font(.system(size: 15, weight: .heavy))
                        .kerning(0.4)
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("\(count) 條")
                        .font(.custom("Times New Roman", size: 12))
                        .italic()
                        .foregroundStyle(AppTheme.mute)
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.width)  // 1:1
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Group detail list

struct CommonClauseGroupView: View {
    let group: CommonClauseGroup
    let groupIndex: Int                     // 0 = 設計階段必查；1–7 = 其他分類
    @EnvironmentObject var store: ArticleStore
    @EnvironmentObject var iap: IAPManager

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            List(group.articleIds, id: \.self) { aid in
                if let a = store.article(by: aid) {
                    CommonClauseRow(
                        article: a,
                        canAccess: iap.canAccess(
                            commonClauseArticleId: aid,
                            groupIndex: groupIndex,
                            allIdsInGroup: group.articleIds
                        )
                    )
                    .listRowBackground(AppTheme.paper)
                    .listRowSeparatorTint(AppTheme.line)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(group.title)
    }
}

// MARK: - Article row with lock support

private struct CommonClauseRow: View {
    let article: Article
    let canAccess: Bool

    var body: some View {
        NavigationLink {
            if canAccess {
                ArticleTextView(article: article, illustrationAccessOverride: true)
            } else {
                PaywallView()
            }
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.article_no)
                        .font(.custom("Times New Roman", size: 11)).italic()
                        .foregroundStyle(canAccess ? AppTheme.rust : AppTheme.mute)
                    Text(article.title_zh)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(canAccess ? AppTheme.primary : AppTheme.mute)
                    Text(article.summary)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.mute)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
                Spacer()
                if !canAccess {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mute.opacity(0.6))
                        .padding(.leading, 8)
                }
            }
        }
    }
}
