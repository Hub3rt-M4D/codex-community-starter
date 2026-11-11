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
    func testCompletionCountPresentationAndPersistence() {
        app.launch()
        let count = app.staticTexts["pendingCount"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        XCTAssertEqual(count.label, "Pending: 0")
        let field = app.textFields["taskTitle"]
        for title in ["First", "Second"] {
            field.tap()
            field.typeText(title)
            app.buttons["Add"].tap()
        }
        XCTAssertEqual(count.label, "Pending: 2")
        let control = app.buttons["Mark complete: First"]
        XCTAssertEqual(control.value as? String, "Incomplete")
        control.tap()
        XCTAssertEqual(count.label, "Pending: 1")
        XCTAssertTrue(app.staticTexts["Completed"].exists)
        XCTAssertEqual(app.buttons["Mark incomplete: First"].value as? String, "Completed")
        XCTAssertEqual(app.buttons["Mark complete: Second"].value as? String, "Incomplete")
        XCTAssertLessThan(app.staticTexts["First"].frame.minY, app.staticTexts["Second"].frame.minY)

        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launch()
        let reopen = app.buttons["Mark incomplete: First"]
        XCTAssertTrue(reopen.waitForExistence(timeout: 5))
        XCTAssertEqual(count.label, "Pending: 1")
        reopen.tap()
        XCTAssertEqual(count.label, "Pending: 2")
        XCTAssertFalse(app.staticTexts["Completed"].exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Mark complete: First"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["Mark complete: First"].value as? String, "Incomplete")
        XCTAssertEqual(count.label, "Pending: 2")
        XCTAssertTrue(app.staticTexts["Second"].exists)
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
