//
//  TaskyUITests.swift
//  TaskyUITests
//
//  Created by Joey Tawadrous on 31/03/2018.
//  Copyright © 2018 Joey Tawadrous. All rights reserved.
//

import XCTest

class TaskyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
		
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
		let app = XCUIApplication()
		app.navigationBars["Goals"].buttons[""].tap()
		app/*@START_MENU_TOKEN@*/.buttons["Close"]/*[[".otherElements[\"SCLAlertView\"].buttons[\"Close\"]",".buttons[\"Close\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		
		snapshot("Goals")
		app.tables/*@START_MENU_TOKEN@*/.staticTexts["Become Master Cook"]/*[[".cells.staticTexts[\"Become Master Cook\"]",".staticTexts[\"Become Master Cook\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		snapshot("Tasks")
		app.tables/*@START_MENU_TOKEN@*/.staticTexts["Meal prep"]/*[[".cells.staticTexts[\"Meal prep\"]",".staticTexts[\"Meal prep\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		snapshot("Task")
    }
}
