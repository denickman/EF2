//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.12.2024.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    // since class has only static func let`s make init private
    
    private init() {}
    
    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    // [FeedImage] -> Adapter -> [FeedImageCellController]
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(
                    viewModel: FeedImageViewModel(
                        model: model,
                        imageLoader: loader,
                        imageTransformer: UIImage.init
                    )
                )
            }
        }
    }
}
