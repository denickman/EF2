//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 19.11.2024.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
