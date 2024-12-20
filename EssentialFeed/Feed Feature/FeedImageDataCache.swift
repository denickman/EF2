//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.12.2024.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

