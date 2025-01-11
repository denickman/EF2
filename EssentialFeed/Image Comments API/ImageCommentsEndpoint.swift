//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 09.01.2025.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let id):
            return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
