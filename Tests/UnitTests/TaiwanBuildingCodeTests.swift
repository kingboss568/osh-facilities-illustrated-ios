import XCTest
@testable import TaiwanBuildingCode

final class TaiwanBuildingCodeTests: XCTestCase {
    func testToolCatalogContainsOneHundredUniqueWorkingTools() {
        XCTAssertEqual(SafetyToolCatalog.groups.count, 10)
        XCTAssertEqual(SafetyToolCatalog.tools.count, 100)
        XCTAssertEqual(Set(SafetyToolCatalog.tools.map(\.id)).count, 100)
        XCTAssertEqual(Set(SafetyToolCatalog.tools.map(\.title)).count, 100)
        XCTAssertTrue(SafetyToolCatalog.tools.allSatisfy { tool in
            tool.checklist.count == 4 &&
            !tool.focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        })
    }

    @MainActor
    func testRealSearchMatchesArticleFieldsAndReturnsNavigableRecords() {
        let store = ArticleStore.preview

        XCTAssertEqual(store.search("法源").map(\.id), ["01-001"])
        XCTAssertEqual(store.search("第1條").map(\.id), ["01-001"])
        XCTAssertEqual(store.search("OSH-001").map(\.id), ["01-001"])
        XCTAssertTrue(store.search("不存在的空殼查詢").isEmpty)
        XCTAssertTrue(store.search("   ").isEmpty)
    }

    func testEveryToolBelongsToOneDeclaredTenItemGroup() {
        for group in SafetyToolCatalog.groups {
            XCTAssertEqual(
                SafetyToolCatalog.tools.filter { $0.group == group }.count,
                10,
                "\(group) 必須包含 10 個工具"
            )
        }
        XCTAssertTrue(
            SafetyToolCatalog.tools.allSatisfy {
                SafetyToolCatalog.groups.contains($0.group)
            }
        )
    }
}
