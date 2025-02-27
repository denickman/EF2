//
//  EssentialFeedDataLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 16.12.2024.
//

public protocol FeedImageDataLoaderTask {
    func cancel()
}
// protocol defines to load image data
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
