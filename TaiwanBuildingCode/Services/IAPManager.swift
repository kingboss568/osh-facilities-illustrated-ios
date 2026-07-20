//
//  IAPManager.swift
//  職業安全衛生設施規則全圖解
//
//  StoreKit 2 wrapper for the single non-consumable unlock product.
//

import Foundation
import StoreKit

@MainActor
final class IAPManager: ObservableObject {

    @Published private(set) var isUnlocked: Bool = false
    @Published private(set) var product: Product?
    @Published private(set) var purchaseError: String?
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var isLoadingProduct: Bool = false

    private var transactionTask: Task<Void, Never>?
    private let fallbackDisplayPrice = Constants.fallbackPriceText
    private let isScreenshotMode = ProcessInfo.processInfo.arguments.contains("--screenshot")

    var purchaseButtonPriceText: String {
        fallbackDisplayPrice
    }

    // MARK: - Setup

    func loadProduct() async {
        guard !isScreenshotMode else { return }
        guard !isLoadingProduct else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        purchaseError = nil
        do {
            let products = try await Product.products(for: [Constants.unlockProductID])
            if let product = products.first {
                self.product = product
            } else {
                self.product = nil
            }
        } catch {
            self.product = nil
        }
    }

    func clearPurchaseError() {
        purchaseError = nil
    }

    /// Re-check current entitlements; flips isUnlocked.
    func refreshEntitlements() async {
        guard !isScreenshotMode else {
            self.isUnlocked = false
            return
        }
        await loadProduct()
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Constants.unlockProductID {
                self.isUnlocked = true
                return
            }
        }
        self.isUnlocked = false
    }

    /// Background listener for transactions (refunds, family sharing, etc.)
    func startTransactionListener() async {
        guard !isScreenshotMode else { return }
        transactionTask?.cancel()
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let t) = result {
                    await t.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    // MARK: - User actions

    func purchase() async {
        guard !isScreenshotMode else {
            purchaseError = nil
            return
        }
        if product == nil {
            await loadProduct()
        }
        guard let product else {
            purchaseError = "商品尚未載入完成，請再點一次「立即解鎖」。"
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    await refreshEntitlements()
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "付款待確認，完成後將自動解鎖。"
            @unknown default:
                break
            }
        } catch {
            purchaseError = "購買失敗：\(error.localizedDescription)"
        }
    }

    func restore() async {
        guard !isScreenshotMode else {
            purchaseError = nil
            return
        }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = "恢復購買失敗：\(error.localizedDescription)"
        }
    }

    // MARK: - Gating helper

    /// 圖解存取管控：免費版只開放全系列排序前 20 張，其餘需解鎖。
    func canAccess(article: Article, allArticles: [Article]) -> Bool {
        if isUnlocked { return true }
        let freeArticles = allArticles
            .sorted {
                let left = $0.id
                let right = $1.id
                return left.localizedStandardCompare(right) == .orderedAscending
            }
            .prefix(Constants.freeDesignIllustrationCount)
        let freeIDs = Set(freeArticles.map(\.id))
        return freeIDs.contains(article.id)
    }

    /// 圖解存取管控（輕量版，不需要 allArticles）。
    func canAccessIllustration(for article: Article) -> Bool {
        if isUnlocked { return true }
        let serialText = article.id.split(separator: "-").last.map(String.init) ?? article.id
        guard let n = Int(serialText) else { return false }
        return n <= Constants.freeDesignIllustrationCount
    }

    /// 常用條文存取管控：
    ///   - groupIndex 0（設計階段必查）→ 前 freeCommonClausesFirstGroup 條免費
    ///   - groupIndex 1–7 → 只開放第 freeCommonClausesOtherGroups 條
    func canAccess(commonClauseArticleId: String,
                   groupIndex: Int,
                   allIdsInGroup: [String]) -> Bool {
        if isUnlocked { return true }
        let freeCount = groupIndex == 0
            ? Constants.freeCommonClausesFirstGroup
            : Constants.freeCommonClausesOtherGroups
        return allIdsInGroup.prefix(freeCount).contains(commonClauseArticleId)
    }
}
