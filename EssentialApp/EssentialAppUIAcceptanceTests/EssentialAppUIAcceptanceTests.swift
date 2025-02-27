//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Denis Yaremenko on 20.12.2024.
//

import XCTest

/// Now it it redundant tests since we check the logic in 'FeedAcceptanceTests'

/*
 

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
             let app = XCUIApplication()
             app.launchArguments = ["-reset", "-connectivity", "online"]
             app.launch()

             let feedCells = app.cells.matching(identifier: "feed-image-cell")
        // private func makeFeedData() -> Data in DebuggingSceneDelegate
             XCTAssertEqual(feedCells.count, 2)

             let firstImage = app.images.matching(identifier: "feed-image").firstMatch
             XCTAssertTrue(firstImage.exists)
         }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        // first we have to launch the app with connectivity in order to store feed into the cache
        // then launch it offline to check the cache is exist
             let onlineApp = XCUIApplication()
             onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
             onlineApp.launch()

             let offlineApp = XCUIApplication()
        /// Передача флага через launchArguments: Когда вы вызываете offlineApp.launchArguments = ["-connectivity", "offline"] перед запуском приложения, система автоматически добавляет этот аргумент в UserDefaults.
             offlineApp.launchArguments = ["-connectivity", "offline"]
             offlineApp.launch()

             let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
             XCTAssertEqual(cachedFeedCells.count, 2)

             let firstCachedImage = offlineApp.images.matching(identifier: "feed-image").firstMatch
             XCTAssertTrue(firstCachedImage.exists)
         }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        // no connectivity and no cache
        
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, .zero)
    }
    
}


*/
