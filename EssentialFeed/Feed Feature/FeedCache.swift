//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.12.2024.
//


import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

