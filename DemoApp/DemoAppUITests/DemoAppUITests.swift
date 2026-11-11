import XCTest

final class DemoAppUITests: XCTestCase {
    private var app: XCUIApplication!

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["TASK_TRACKER_TEST_SUITE"] = "TaskTracker.UITests.\(UUID().uuidString)"
        app.launchEnvironment["TASK_TRACKER_RESET"] = "1"
    }

    @MainActor
    override func tearDownWithError() throws {
        app.terminate()
        app.launchEnvironment["TASK_TRACKER_RESET"] = "1"
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_CORRUPT")
        app.launch()
        app.terminate()
    }

    @MainActor
    func testAddValidationAndPersistenceAcrossRelaunch() {
        app.launch()
        let field = app.textFields["taskTitle"]
        let add = app.buttons["Add"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(add.isEnabled)
        field.tap()
        field.typeText("   ")
        XCTAssertFalse(add.isEnabled)
        field.typeText("Workshop task")
        add.tap()
        XCTAssertTrue(app.staticTexts["Workshop task"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts.matching(identifier: "Workshop task").count, 1)
        XCTAssertEqual(field.value as? String, "New task")
        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launch()
        XCTAssertTrue(app.staticTexts["Workshop task"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts.matching(identifier: "Workshop task").count, 1)
    }

    @MainActor
    func testStorageIsolationAcrossSuitesRelaunchAndCleanup() {
        let originalSuite = app.launchEnvironment["TASK_TRACKER_TEST_SUITE"]!
        let title = "Isolation \(UUID().uuidString)"
        app.launch()
        let field = app.textFields["taskTitle"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(title)
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 5))
        app.terminate()

        app.launchEnvironment["TASK_TRACKER_TEST_SUITE"] = "TaskTracker.UITests.\(UUID().uuidString)"
        app.launch()
        XCTAssertTrue(app.textFields["taskTitle"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[title].exists, "A different suite must not see the task")
        app.terminate()

        app.launchEnvironment["TASK_TRACKER_TEST_SUITE"] = originalSuite
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launch()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 5))
        app.terminate()

        // Exercise the same reset launch used by tearDown, then verify it persisted.
        app.launchEnvironment["TASK_TRACKER_RESET"] = "1"
        app.launch()
        XCTAssertTrue(app.textFields["taskTitle"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[title].exists)
        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launch()
        XCTAssertTrue(app.textFields["taskTitle"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[title].exists)
    }

    @MainActor
    func testUnreadableSavedDataShowsErrorAndDisablesAdd() {
        app.launchEnvironment["TASK_TRACKER_CORRUPT"] = "1"
        app.launch()
        XCTAssertTrue(app.staticTexts["loadError"].waitForExistence(timeout: 5))
        let field = app.textFields["taskTitle"]
        field.tap()
        field.typeText("Do not overwrite")
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_CORRUPT")
        app.launch()
        XCTAssertTrue(app.staticTexts["loadError"].waitForExistence(timeout: 5))
    }
}
