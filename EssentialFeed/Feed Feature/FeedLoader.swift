//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import Foundation


enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}


protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
