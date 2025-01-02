//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }

}
