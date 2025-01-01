//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.12.2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    
    // since class has only static func let`s make init private
    
    private init() {}
    
    public static func feedComposedWith(
             feedLoader: @escaping () ->  AnyPublisher<[FeedImage], Error>,
             imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
         ) -> FeedViewController {
             let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeFeedViewController(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
             presentationAdapter.presenter = FeedPresenter(
                          feedView: FeedViewAdapter(
                              controller: feedController,
                              imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
