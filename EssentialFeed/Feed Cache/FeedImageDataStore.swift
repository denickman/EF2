//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 17.12.2024.
//

import Foundation
import Combine

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    /// @available(iOS 15.0, deprecated: 1.0, message: "Use new insert method instead.")
   
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)

    // sync api

    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}


public extension FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        
        var result: InsertionResult!
        
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        return try result.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        
        retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        
        return try result.get() // if it fails it will throw an error from here .get()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
