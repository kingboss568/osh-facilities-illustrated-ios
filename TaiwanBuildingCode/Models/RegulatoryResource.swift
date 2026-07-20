//
//  RegulatoryResource.swift
//  職業安全衛生設施規則全圖解
//

import Foundation

struct RegulatoryResource: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case law = "法規"
        case agency = "機關"
        case guide = "指引"
        case system = "系統"

        var id: String { rawValue }
    }

    let id: String
    let title: String
    let subtitle: String
    let category: Category
    let url: URL
    let symbolName: String
    let keywords: [String]

    static let official: [RegulatoryResource] = [
        .init(
            id: "osh-facilities-rules",
            title: "職業安全衛生設施規則",
            subtitle: "全國法規資料庫：完整條文、附件與最新修正",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0060009")!,
            symbolName: "scroll.fill",
            keywords: ["職業安全衛生設施規則", "N0060009", "設施", "最低標準"]
        ),
        .init(
            id: "osh-act",
            title: "職業安全衛生法",
            subtitle: "職安衛基本法源、雇主責任與安全衛生措施",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0060001")!,
            symbolName: "checkmark.shield.fill",
            keywords: ["職業安全衛生法", "雇主", "勞工", "責任"]
        ),
        .init(
            id: "osha",
            title: "勞動部職業安全衛生署",
            subtitle: "職安衛公告、教材、指引與專區",
            category: .agency,
            url: URL(string: "https://www.osha.gov.tw/")!,
            symbolName: "building.columns.fill",
            keywords: ["職安署", "勞動部", "公告", "教材"]
        ),
        .init(
            id: "law-search-system",
            title: "全國法規資料庫",
            subtitle: "查詢法規條文、沿革、主管機關與附件",
            category: .system,
            url: URL(string: "https://law.moj.gov.tw/")!,
            symbolName: "network",
            keywords: ["全國法規資料庫", "法規查詢", "沿革"]
        ),
        .init(
            id: "hazard-communication",
            title: "危害性化學品標示及通識規則",
            subtitle: "SDS、標示、通識與化學品管理",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0060050")!,
            symbolName: "testtube.2",
            keywords: ["SDS", "化學品", "標示", "通識"]
        ),
        .init(
            id: "osh-training",
            title: "職業安全衛生教育訓練規則",
            subtitle: "入場、一般與特殊作業教育訓練依據",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0060023")!,
            symbolName: "graduationcap.fill",
            keywords: ["教育訓練", "特殊作業", "入場"]
        ),
        .init(
            id: "osh-guides",
            title: "職安衛指引與宣導教材",
            subtitle: "作業安全、危害預防與現場改善參考",
            category: .guide,
            url: URL(string: "https://www.osha.gov.tw/48110/")!,
            symbolName: "doc.text.magnifyingglass",
            keywords: ["指引", "宣導", "教材", "改善"]
        )
    ]

    static func filtered(query: String, category: Category?) -> [RegulatoryResource] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return official.filter { resource in
            let categoryMatches = category == nil || resource.category == category
            guard !normalized.isEmpty else { return categoryMatches }
            let haystack = ([resource.title, resource.subtitle, resource.category.rawValue] + resource.keywords)
                .joined(separator: " ")
            return categoryMatches && haystack.localizedCaseInsensitiveContains(normalized)
        }
    }
}
