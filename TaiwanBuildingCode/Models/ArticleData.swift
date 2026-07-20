//
//  ArticleData.swift
//  職業安全衛生設施規則全圖解
//
//  Decodable models matching articles.json shipped in /Resources/data/articles.json
//

import Foundation

// MARK: - Root payload

struct ArticleBundle: Decodable {
    let series: SeriesMeta
    let chapters: [Chapter]
    let articles: [Article]
}

struct SeriesMeta: Decodable {
    let title_zh: String
    let title_en: String
    let subtitle_zh: String
    let version: String
    let language: String
    let source: String
    let publisher: String
    let total_articles: Int
    let chapters: Int
}

// MARK: - Chapter

struct Chapter: Decodable, Identifiable, Hashable {
    let id: String          // "01" .. "08"
    let title_zh: String
    let title_en: String
    let intro: String

    /// Series id derived from chapter number (threshold/equipment/egress-rescue)
    var seriesId: String { Constants.seriesId(forChapter: id) }
}

// MARK: - Article

struct Article: Decodable, Identifiable, Hashable {
    let id: String          // "01-01" .. "08-20"
    let chapter: String     // "01" .. "08"
    let article_no: String  // "第1條(2)" / "設備編 第133條"
    let title_zh: String
    let title_en: String
    let key_visual: String  // 圖解視覺重點
    let summary: String     // 條文摘要
    let filename: String    // image basename (no extension)

    /// Image asset name (matches Resources/images/<filename>.heic)
    var imageAssetName: String { filename }

    /// Series id derived from chapter number
    var seriesId: String { Constants.seriesId(forChapter: chapter) }

    /// Numeric sort key inside chapter ("01-07" -> 7)
    var serial: Int {
        let parts = id.split(separator: "-")
        guard parts.count == 2, let n = Int(parts[1]) else { return 0 }
        return n
    }
}
