//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
