//
//  EssentialFeedDataLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 16.12.2024.
//


public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
