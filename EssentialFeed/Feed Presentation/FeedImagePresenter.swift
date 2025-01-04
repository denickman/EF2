//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.12.2024.
//

import Foundation

public final class FeedImagePresenter {
    
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        return FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}

