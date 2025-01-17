//
//  NullStore.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 14.01.2025.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore {
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }

}

extension NullStore: FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
    
    func insert(_ data: Data, for url: URL) throws {
        
    }
}
