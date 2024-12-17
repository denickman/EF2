//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 19.11.2024.
//

import Foundation

// use cases encapsulate application specific business logic and LocalFeedLoader implements use cases,
// the colloborating with other types, so it acts like a controller

public final class LocalFeedLoader {
    // like a controller, interactor, use case etc.
    // it holds application specific business logic
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self else {return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in // request (return the value but not change the state)
            guard let self else { return }
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
                //            case .success(.found), .success(.empty):
            case .success: // simplified
                // found but not valid (because of more than 7 days old)
                //                self.store.deleteCachedFeed { _ in } // side effect
                completion(.success([]))
                
            case .failure(let error):
                //                self.store.deleteCachedFeed { _ in  } // side effect
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in completion(.success(())) }
                
            case .failure: // expired cache?
                self.store.deleteCachedFeed { _ in completion(.success(())) }
                
                //            case .success(.empty), .success(.found): break
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
