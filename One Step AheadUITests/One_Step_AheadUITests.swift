//
//  One_Step_AheadUITests.swift
//  One Step AheadUITests
//
//  Created by Ethan Marshall on 5/16/22.
//

import XCTest

final class One_Step_AheadUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    /// Launches the app and dismisses the Game Center sign-in prompt if it appears.
    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        
        if app.buttons["Cancel"].waitForExistence(timeout: 3) {
            app.buttons["Cancel"].tap()
        }
        return app
    }
    
    /// Attaches a screenshot of the app to the test results.
    @MainActor
    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - One Step Ahead UI Tests
    
    @MainActor
    func testAppExistence() throws {
        let app = launchApp()
        XCTAssert(app.exists)
    }
    
    @MainActor
    func testTitleScreen() throws {
        let app = launchApp()
        
        XCTAssertTrue(app.buttons["Start Game"].waitForExistence(timeout: 30), "The Start Game button should appear once Game Center authentication finishes.")
        attachScreenshot(of: app, named: "Title Screen")
    }
    
    @MainActor
    func testMainMenu() throws {
        let app = launchApp()
        
        XCTAssertTrue(app.buttons["Start Game"].waitForExistence(timeout: 30))
        app.buttons["Start Game"].tap()
        
        XCTAssertTrue(app.staticTexts["TUTORIAL"].waitForExistence(timeout: 10), "The main menu should offer the tutorial.")
        attachScreenshot(of: app, named: "Main Menu")
    }

    @MainActor
    func testGalleryOpensFromMainMenu() throws {
        let app = launchApp()
        
        XCTAssertTrue(app.buttons["Start Game"].waitForExistence(timeout: 30))
        app.buttons["Start Game"].tap()
        XCTAssertTrue(app.staticTexts["GALLERY"].waitForExistence(timeout: 10))
        
        // Record the layout so regressions in the menu's hit-testing are easy to diagnose
        print("[Layout] window=\(app.windows.firstMatch.frame) tutorial=\(app.staticTexts["TUTORIAL"].frame) gallery=\(app.staticTexts["GALLERY"].frame) newGame=\(app.staticTexts["NEW GAME"].frame)")
        
        // The Gallery square sits near the top edge in landscape, where iOS 26's navigation bar would swallow taps if it were shown
        app.staticTexts["GALLERY"].tap()
        XCTAssertTrue(app.staticTexts["Gallery Completion"].waitForExistence(timeout: 10), "Tapping the GALLERY square should open the Drawing Gallery.")
        attachScreenshot(of: app, named: "Gallery")
    }
}
