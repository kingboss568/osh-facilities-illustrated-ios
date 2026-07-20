//
//  SearchView.swift
//  Cross-tab article search.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var store: ArticleStore
    @State private var query = ""
    @AppStorage("recentSearches") private var recentRaw = ""

    private var recents: [String] {
        recentRaw.split(separator: "\u{1F}").map(String.init)
    }

    private var results: [Article] {
        query.isEmpty ? [] : store.search(query)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("搜尋條文編號、關鍵字、圖解編號…", text: $query)
                    .submitLabel(.search)
                    .onSubmit { saveRecent(query) }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(AppTheme.cardBG, in: RoundedRectangle(cornerRadius: 10))
            .padding()

            if query.isEmpty && !recents.isEmpty {
                List {
                    Section("最近搜尋") {
                        ForEach(recents, id: \.self) { r in
                            Button(r) { query = r }
                        }
                    }
                }
            } else {
                List(results) { a in
                    NavigationLink {
                        ArticleTextView(article: a)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(a.id).font(.caption.monospaced())
                                Text(a.article_no).font(.caption).foregroundStyle(.secondary)
                            }
                            Text(a.title_zh).font(.body)
                            Text(a.summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("搜尋")
    }

    private func saveRecent(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var arr = recents.filter { $0 != trimmed }
        arr.insert(trimmed, at: 0)
        if arr.count > 10 { arr = Array(arr.prefix(10)) }
        recentRaw = arr.joined(separator: "\u{1F}")
    }
}
