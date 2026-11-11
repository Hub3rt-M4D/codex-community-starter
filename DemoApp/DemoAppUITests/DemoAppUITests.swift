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
    func testCompletionPresentationCountsAndBothDirectionsSurviveRelaunch() {
        app.launch()
        let pending = app.staticTexts["pendingCount"]
        XCTAssertTrue(pending.waitForExistence(timeout: 5))
        XCTAssertEqual(pending.label, "Pending: 0")
        for title in ["First", "Second"] {
            let field = app.textFields["taskTitle"]
            field.tap()
            field.typeText(title)
            app.buttons["Add"].tap()
        }
        XCTAssertEqual(pending.label, "Pending: 2")
        let complete = app.buttons["Mark First complete"]
        XCTAssertEqual(complete.value as? String, "Incomplete")
        complete.tap()
        XCTAssertEqual(pending.label, "Pending: 1")
        XCTAssertEqual(app.buttons["Mark First incomplete"].value as? String, "Completed")
        XCTAssertTrue(app.staticTexts["Completed"].exists)
        XCTAssertTrue(app.staticTexts["First"].exists)
        XCTAssertTrue(app.staticTexts["Second"].exists)
        XCTAssertLessThan(app.staticTexts["First"].frame.minY, app.staticTexts["Second"].frame.minY)
        XCTAssertEqual(app.buttons["Mark Second complete"].value as? String, "Incomplete")

        app.terminate()
        app.launchEnvironment.removeValue(forKey: "TASK_TRACKER_RESET")
        app.launch()
        let undo = app.buttons["Mark First incomplete"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        XCTAssertEqual(undo.value as? String, "Completed")
        XCTAssertEqual(pending.label, "Pending: 1")
        XCTAssertTrue(app.staticTexts["Completed"].exists)
        undo.tap()
        XCTAssertEqual(pending.label, "Pending: 2")
        XCTAssertFalse(app.staticTexts["Completed"].exists)

        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Mark First complete"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["Mark First complete"].value as? String, "Incomplete")
        XCTAssertEqual(pending.label, "Pending: 2")
        XCTAssertFalse(app.staticTexts["Completed"].exists)
        XCTAssertLessThan(app.staticTexts["First"].frame.minY, app.staticTexts["Second"].frame.minY)
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
