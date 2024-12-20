//
//  FeedLoaderStub.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 20.12.2024.
//

import EssentialFeed

final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
