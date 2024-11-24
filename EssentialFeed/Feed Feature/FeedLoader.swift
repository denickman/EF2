//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import Foundation

// <FeedLoader>

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
