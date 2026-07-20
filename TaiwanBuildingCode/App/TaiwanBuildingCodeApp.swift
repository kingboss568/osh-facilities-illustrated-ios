//
//  TaiwanBuildingCodeApp.swift
//  職業安全衛生設施規則全圖解
//
//  Created by @iOS-Dev for @Jiang on 2026-05-08.
//

import SwiftUI

@main
struct TaiwanBuildingCodeApp: App {

    // MARK: - Global services
    @StateObject private var articleStore = ArticleStore()
    @StateObject private var bookmarkStore = BookmarkStore()
    @StateObject private var iapManager = IAPManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(articleStore)
                .environmentObject(bookmarkStore)
                .environmentObject(iapManager)
                .task {
                    await iapManager.refreshEntitlements()
                    await iapManager.startTransactionListener()
                }
        }
    }
}
