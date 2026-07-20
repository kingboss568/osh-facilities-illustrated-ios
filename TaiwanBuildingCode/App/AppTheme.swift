//
//  AppTheme.swift
//  職業安全衛生設施規則全圖解
//
//  Centralized colors & typography — 職安設施專業設計系統 v1
//

import SwiftUI

enum AppTheme {
    // ─── 主要品牌色 ───────────────────────────────────────────
    /// 圖面墨綠 / plan ink
    static let primary       = Color(red: 0.061, green: 0.188, blue: 0.169)
    /// 警示重點紅 / risk seal
    static let rust          = Color(red: 0.690, green: 0.247, blue: 0.196)

    // ─── 紙本背景 ─────────────────────────────────────────────
    /// 建築圖面白 / paper
    static let paper         = Color(red: 0.972, green: 0.980, blue: 0.969)
    /// 圖紙暖灰 / kraft
    static let kraft         = Color(red: 0.918, green: 0.925, blue: 0.898)
    /// 淺圖紙背景
    static let paperBG       = Color(red: 0.929, green: 0.955, blue: 0.941)

    // ─── 職業安全系列配色 ───────────────────────────────────
    static let designSeries  = Color(red: 0.125, green: 0.384, blue: 0.333)
    static let structSeries  = Color(red: 0.118, green: 0.298, blue: 0.459)
    static let equipSeries   = Color(red: 0.553, green: 0.392, blue: 0.129)

    // ─── 等角圖面輔助色 ───────────────────────────────────────
    /// 淡法務藍 / sky
    static let sky           = Color(red: 0.690, green: 0.792, blue: 0.812)
    /// 登記暖金 / gold
    static let gold          = Color(red: 0.879, green: 0.680, blue: 0.322)
    /// 靜音灰棕 / mute   #8a8377  次要文字
    static let mute          = Color(red: 0.541, green: 0.514, blue: 0.467)
    /// 分隔線 / line     #e6e1d4
    static let line          = Color(red: 0.902, green: 0.882, blue: 0.831)
    /// 葉綠 / leaf       #7d8f60
    static let leaf          = Color(red: 0.490, green: 0.561, blue: 0.376)
    static let blueprint     = Color(red: 0.153, green: 0.220, blue: 0.267)
    static let resourceBlue  = Color(red: 0.082, green: 0.333, blue: 0.322)
    static let resourceSurface = Color(red: 0.918, green: 0.953, blue: 0.941)

    // ─── 計算結果三段式回饋 ────────────────────────────────────
    static let pass          = Color.green
    static let warn          = Color.orange
    static let fail          = Color.red

    // ─── 通用背景 ─────────────────────────────────────────────
    static let cardBG        = Color(.secondarySystemBackground)

    // ─── 已棄用相容名稱（保留以防其他舊檔引用） ──────────────
    static var accentBlue: Color { sky }
    static var accentGold: Color { gold }

    // ─── Series helper ─────────────────────────────────────────
    static func color(for seriesId: String) -> Color {
        switch seriesId {
        case "general": return designSeries
        case "machine": return resourceBlue
        case "height": return rust
        case "hazard": return gold
        case "hygiene": return leaf
        default:        return primary
        }
    }
}
