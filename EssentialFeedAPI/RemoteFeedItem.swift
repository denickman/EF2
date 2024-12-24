//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.11.2024.
//


import Foundation

public struct RemoteFeedItem: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
}
