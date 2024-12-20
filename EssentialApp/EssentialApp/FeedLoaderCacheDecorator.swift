//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 20.12.2024.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    /// in order to not add save method to the feed loader we use decorator to make this
    
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            /// #option 1
//            if let feed = try? result.get() {
//                self?.cache.save(feed) { _ in }
//            }
            
            /// #option 2
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
