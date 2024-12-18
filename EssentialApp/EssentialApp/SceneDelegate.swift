//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 17.12.2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
//        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
//        let session = URLSession(configuration: .ephemeral)
//        
//        let client = URLSessionHTTPClient(session: session)
//        let feedLoader = RemoteFeedLoader(url: url, client: client)
//        let imageLoader = RemoteFeedImageDataLoader(client: client)
//        
//        let feedViewController = FeedUIComposer.feedComposeWith(feedLoader: feedLoader, imageLoader: imageLoader)
//        
//        window?.rootViewController = feedViewController
        

        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        
        let remoteClient = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)

        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        let feedLoader = FeedLoaderWithFallbackComposite(primary: remoteFeedLoader, fallback: localFeedLoader)
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: remoteImageLoader)
        
        window?.rootViewController = FeedUIComposer.feedComposeWith(feedLoader: feedLoader, imageLoader: imageLoader)
    }
}

