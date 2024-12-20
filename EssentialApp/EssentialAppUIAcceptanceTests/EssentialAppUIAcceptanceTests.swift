//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Denis Yaremenko on 20.12.2024.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        
        let firstCell = app.cells.firstMatch
        let image = firstCell.images.matching(identifier: "feed-image").firstMatch
        
        XCTAssertTrue(firstCell.exists, "First cell should exist")
        XCTAssertTrue(image.exists, "Image in the first cell should exist")
    }
    
}
