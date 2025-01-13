//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.01.2025.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            let url = baseURL.appendingPathComponent("/v1/feed")
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            
            return components.url!
        }
    }
}
