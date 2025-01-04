//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.12.2024.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        location != nil
    }
}

