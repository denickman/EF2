//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 10.11.2024.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    /// the completion handler can be invoked in any thread
    /// clients are responsible to dispatch to appropriate threads, if needed
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

