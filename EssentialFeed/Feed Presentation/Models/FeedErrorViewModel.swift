//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel.init(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
