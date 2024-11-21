//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.11.2024.
//

import Foundation

// so in order to decouple rigit connections between modules we add intermediate data model - LocalFeedItem
// this is a mirror of a FeedItem but a local representation

public struct LocalFeedImage: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

