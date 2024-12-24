//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 24.12.2024.
//

// So in order to decouple rigit connections between modules we add intermediate data model - LocalFeedItem
// this is a mirror of a FeedItem but a local representation

// Codable - in order to not make a rigit connection to CodableFeedStore we do not use Codable for LocalFeedImage
// instead we add internal model inside CodableFeedStore like CodableFeedImage

// so we move conformance from the framework agnostic "localfeedimage" type to the new framework - specific "CodableFeedImage" type. this type is a private within a framework implementation, since the 'codable' requirement is a framework-specific detail

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
