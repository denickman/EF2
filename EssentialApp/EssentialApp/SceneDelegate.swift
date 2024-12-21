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
        
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.squlite")
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        window?.rootViewController = FeedUIComposer.feedComposeWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)))
    }
    
    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()
            
        default:
            return URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        }
    }
    
    private class AlwaysFailingHTTPClient: HTTPClient {
        
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(.failure(NSError.init(domain: "offline", code: 0)))
            return Task()
        }
    }
}

/*
 
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
 
 let primaryFeedLoader = FeedLoaderWithFallbackComposite(
 primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
 fallback: localFeedLoader
 )
 
 let imageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader))
 
 window?.rootViewController = FeedUIComposer.feedComposeWith(feedLoader: primaryFeedLoader, imageLoader: imageLoader)
 
 
 // in order to test local loaders use this after loading from remote server
 //        window?.rootViewController = FeedUIComposer.feedComposeWith(feedLoader: localFeedLoader, imageLoader: localFeedLoader)
 }
 }
 
 
 
 */
