//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 31.12.2024.
//

import Foundation

public final class RemoteLoader: FeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
           
            switch result {
            case .success(let data, let response):
                completion(RemoteLoader.map(data, response: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items)
        } catch (let error) {
            return .failure(Error.invalidData)
        }
    }
}
