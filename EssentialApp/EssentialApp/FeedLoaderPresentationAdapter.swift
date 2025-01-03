//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    private let feedLoader: () ->  AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    
    init(feedLoader: @escaping () ->  AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
    }
}
