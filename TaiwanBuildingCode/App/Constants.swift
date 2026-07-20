//
//  Constants.swift
//  職業安全衛生設施規則全圖解
//

import Foundation

enum Constants {
    static let unlockProductID = "com.taiwanarch.oshfacilities.illustrated.full"
    static let fallbackPriceText = "NT$390"

    /// 圖解：免費開放前 20 張，完整 250 張需 Pro 解鎖。
    static let freeDesignIllustrationCount = 20
    static let freeQuizQuestionCount = 20
    static let freeBookmarkLimit = 3
    static let freeCommonClausesFirstGroup = 2
    static let freeCommonClausesOtherGroups = 1

    static func seriesId(forChapter chapter: String) -> String {
        switch chapter {
        case "01": return "general"
        case "02": return "machine"
        case "03": return "height"
        case "04": return "hazard"
        case "05": return "hygiene"
        default: return "general"
        }
    }

    static func seriesName(forSeriesId id: String) -> String {
        switch id {
        case "general": return "總則危害"
        case "machine": return "機械車輛"
        case "height": return "高處通道"
        case "hazard": return "電氣化學"
        case "hygiene": return "衛生防護"
        default: return id
        }
    }

    static let legalDisclaimer =
        "本 App 為職業安全衛生設施規則圖解、測驗與現場檢核輔助；正式法規適用、稽核與改善責任，仍應以主管機關最新公告、全國法規資料庫、現場危害評估與職安衛專業人員判斷為準。"
}
