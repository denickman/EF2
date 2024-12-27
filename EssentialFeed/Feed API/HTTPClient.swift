//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 10.11.2024.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// the completion handler can be invoked in any thread
    /// clients are responsible to dispatch to appropriate threads, if needed
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

