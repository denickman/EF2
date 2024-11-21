//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import Foundation

// <FeedLoader>
public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    // <FeedLoader>
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
