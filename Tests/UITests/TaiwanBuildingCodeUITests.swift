import XCTest

final class TaiwanBuildingCodeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--screenshot"]
        app.launch()
        XCTAssertTrue(
            app.descendants(matching: .any)["home-search-field"].waitForExistence(timeout: 15)
        )
    }

    func testHomeSearchReturnsTappableRealResult() {
        let search = app.descendants(matching: .any)["home-search-field"]
        search.tap()
        search.typeText("法源")

        let result = app.descendants(matching: .any)["home-search-result-01-001"]
        XCTAssertTrue(result.waitForExistence(timeout: 8))
        result.tap()

        XCTAssertTrue(app.navigationBars["第1條｜法源依據"].waitForExistence(timeout: 8))
    }

    func testCategoryOpensPinterestGalleryWithTwoColumns() {
        let category = app.descendants(matching: .any)["home-category-general"]
        XCTAssertTrue(category.waitForExistence(timeout: 8))
        category.tap()

        let first = app.descendants(matching: .any)["gallery-card-01-001"]
        let second = app.descendants(matching: .any)["gallery-card-01-002"]
        XCTAssertTrue(first.waitForExistence(timeout: 8))
        XCTAssertTrue(second.exists)
        XCTAssertNotEqual(first.frame.midX, second.frame.midX)
    }

    func testGalleryTabSearchFiltersAndCardsRemainNavigable() {
        app.descendants(matching: .any)["tab-2"].tap()
        let field = app.descendants(matching: .any)["gallery-search-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.tap()
        field.typeText("法源")

        let first = app.descendants(matching: .any)["gallery-card-01-001"]
        XCTAssertTrue(first.waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["gallery-result-count"].label.contains("1"))
        first.tap()
        XCTAssertTrue(app.navigationBars["第1條｜法源依據"].waitForExistence(timeout: 8))
    }

    func testToolCanBeSearchedOpenedCheckedAndNoted() {
        app.descendants(matching: .any)["tab-4"].tap()
        let field = app.descendants(matching: .any)["tools-search-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.tap()
        field.typeText("開工前危害辨識")

        let tool = app.descendants(matching: .any)["tool-1"]
        XCTAssertTrue(tool.waitForExistence(timeout: 8))
        tool.tap()

        let check = app.descendants(matching: .any)["tool-check-0"]
        XCTAssertTrue(check.waitForExistence(timeout: 8))
        check.tap()
        XCTAssertTrue(app.staticTexts["已完成 1 / 4 項"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["tool-risk-result"].exists)

        let notes = app.descendants(matching: .any)["tool-notes"]
        notes.tap()
        notes.typeText("現場已確認")
        let saved = expectation(
            for: NSPredicate(format: "value CONTAINS %@", "現場已確認"),
            evaluatedWith: notes
        )
        wait(for: [saved], timeout: 5)
    }

    func testProButtonUsesClearCopyAndOpensPaywall() {
        let pro = app.descendants(matching: .any)["home-pro-unlock"]
        XCTAssertTrue(pro.waitForExistence(timeout: 8))
        XCTAssertTrue(pro.label.contains("Pro"))
        XCTAssertTrue(pro.label.contains("解鎖完整圖解"))
        pro.tap()
        XCTAssertTrue(app.staticTexts["解鎖完整圖解"].waitForExistence(timeout: 8))
    }
}
