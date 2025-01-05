//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import XCTest
@testable import EssentialApp
import EssentialFeediOS

class SceneDelegateTests: XCTestCase {
    
    func test_confgireWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        // In iOS 15 and later, the value of this property is true when the window is the key window of its scene.
        // This means, we can only make a UIWindow become key if it's part of a scene.
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
        
        // do not work it anymore since iOS 15
//        XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
//        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_configureWindow_configuresRootViewController() {
        
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }
}


private class UIWindowSpy: UIWindow {
    var makeKeyAndVisibleCallCount = 0
    
    override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
    }
}
