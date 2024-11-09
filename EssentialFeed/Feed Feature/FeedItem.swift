//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import Foundation


public struct FeedItem: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}



//public struct FeedItem: Decodable, Equatable {
//    
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case description
//        case location
//        case imageURL = "image"
//    }
//    
//    public let id: UUID
//    public let description: String?
//    public let location: String?
//    public let imageURL: URL
//    
//    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
//        self.id = id
//        self.description = description
//        self.location = location
//        self.imageURL = imageURL
//    }
//}


