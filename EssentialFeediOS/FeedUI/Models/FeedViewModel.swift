//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 08.12.2024.
//

import UIKit
import EssentialFeed

final class FeedViewModel {
    
    typealias Observer<T> = (T) -> Void

    // MARK: - Properties
    
    var onLoadingStateChange: (Observer<Bool>)?
    var onFeedLoad: (Observer<[FeedImage]>)?

    // MARK: - Private
    
    private let feedLoader: FeedLoader

    // MARK: - Init
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // MARK: - Method
    
    func loadFeed() {
        onLoadingStateChange?(true)
        
        feedLoader.load {[weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
