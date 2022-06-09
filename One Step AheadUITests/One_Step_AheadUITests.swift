//
//  One_Step_AheadUITests.swift
//  One Step AheadUITests
//
//  Created by Ethan Marshall on 5/16/22.
//

import XCTest

class One_Step_AheadUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - One Step Ahead UI Tests
    
    func testAppExistence() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.exists)
    }
    
    func testTitleScreen() throws {
        let app = XCUIApplication()
        app.launch()
        
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        }
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Title Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testInfoView() throws {
        let app = XCUIApplication()
        app.launch()
        
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        }
        app.buttons["Info"].tap()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Main Menu"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
