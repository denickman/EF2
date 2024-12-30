//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.12.2024.
//

import Foundation

public final class RemoteImageCommentsLoader: FeedLoader {
    
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
                completion(RemoteImageCommentsLoader.map(data, response: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch (let error) {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}

