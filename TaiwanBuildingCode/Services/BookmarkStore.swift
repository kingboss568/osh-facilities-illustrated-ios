//
//  BookmarkStore.swift
//  職業安全衛生設施規則全圖解
//
//  Tracks bookmarked article IDs in UserDefaults + iCloud KV (after unlock).
//

import Foundation
import Combine

@MainActor
final class BookmarkStore: ObservableObject {
    @Published private(set) var ids: Set<String> = []
    private let defaults = UserDefaults.standard
    private let key = "bookmarked.article.ids"

    init() {
        let arr = defaults.stringArray(forKey: key) ?? []
        self.ids = Set(arr)
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    /// Toggle. Returns false if free-tier limit was hit (caller may show paywall).
    @discardableResult
    func toggle(_ id: String, isUnlocked: Bool) -> Bool {
        if ids.contains(id) {
            ids.remove(id)
            persist()
            return true
        }
        if !isUnlocked && ids.count >= Constants.freeBookmarkLimit {
            return false
        }
        ids.insert(id)
        persist()
        return true
    }

    private func persist() {
        defaults.set(Array(ids), forKey: key)
        // After unlock you can also push to NSUbiquitousKeyValueStore here.
    }
}
