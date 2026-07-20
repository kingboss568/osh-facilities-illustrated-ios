//
//  ArticleStore.swift
//  職業安全衛生設施規則全圖解
//
//  Loads articles.json from the app bundle and exposes derived collections.
//

import Foundation
import Combine

@MainActor
final class ArticleStore: ObservableObject {

    @Published private(set) var bundle: ArticleBundle?
    @Published private(set) var loadError: String?

    init(autoload: Bool = true) {
        if autoload { load() }
    }

    func load() {
        // 必須在背景執行緒讀取，避免主執行緒 blocking I/O 觸發 watchdog (SIGKILL)
        Task {
            guard let url = Bundle.main.url(forResource: "articles", withExtension: "json") else {
                self.loadError = "articles.json not found in bundle"
                return
            }
            do {
                let decoded = try await Task.detached(priority: .userInitiated) {
                    let raw = try Data(contentsOf: url)
                    return try JSONDecoder().decode(ArticleBundle.self, from: raw)
                }.value
                self.bundle = decoded
                self.loadError = nil
            } catch {
                self.loadError = error.localizedDescription
            }
        }
    }

    // MARK: - Derived collections

    var allArticles: [Article] { bundle?.articles ?? [] }
    var allChapters: [Chapter] { bundle?.chapters ?? [] }

    func articles(inChapter id: String) -> [Article] {
        allArticles.filter { $0.chapter == id }.sorted { $0.serial < $1.serial }
    }

    func articles(inSeries seriesId: String) -> [Article] {
        allArticles.filter { $0.seriesId == seriesId }
    }

    func chapters(inSeries seriesId: String) -> [Chapter] {
        allChapters.filter { $0.seriesId == seriesId }
    }

    func article(by id: String) -> Article? {
        allArticles.first { $0.id == id }
    }

    func chapter(by id: String) -> Chapter? {
        allChapters.first { $0.id == id }
    }

    // MARK: - Search

    /// Simple linear search across title_zh / title_en / summary / key_visual / article_no.
    /// 250 entries is small enough for a linear scan.
    func search(_ q: String) -> [Article] {
        let needle = q.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return [] }
        return allArticles.filter { a in
            a.title_zh.lowercased().contains(needle) ||
            a.title_en.lowercased().contains(needle) ||
            a.summary.lowercased().contains(needle) ||
            a.key_visual.lowercased().contains(needle) ||
            a.article_no.lowercased().contains(needle) ||
            a.id.contains(needle)
        }
    }

    // MARK: - Preview

    static var preview: ArticleStore {
        let s = ArticleStore(autoload: false)
        let sampleSeries = SeriesMeta(
            title_zh: "職業安全衛生設施規則全圖解",
            title_en: "Occupational Safety and Health Facilities Rules Illustrated",
            subtitle_zh: "250 張職安設施規則圖解、測驗與工具",
            version: "1.0", language: "zh-TW",
            source: "全國法規資料庫：職業安全衛生設施規則",
            publisher: "Yu Shiung Jiang",
            total_articles: 1, chapters: 1
        )
        let sampleChapter = Chapter(id: "01",
                                    title_zh: "總則與危害辨識",
                                    title_en: "General and Hazard Recognition",
                                    intro: "最低標準、危險物與作業前辨識。")
        let sampleArticle = Article(id: "01-001", chapter: "01",
                                    article_no: "第1條",
                                    title_zh: "第1條｜法源依據",
                                    title_en: "OSH-001",
                                    key_visual: "職安設施規則圖解",
                                    summary: "本規則依職業安全衛生法第六條第三項規定訂定之。",
                                    filename: "OSH-001")
        s.bundle = ArticleBundle(series: sampleSeries,
                                 chapters: [sampleChapter],
                                 articles: [sampleArticle])
        return s
    }
}
