//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 17.12.2024.
//

import UIKit
import EssentialFeed
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
    private lazy var remoteFeedLoader = httpClient.getPublisher(url: remoteURL)
     
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.squlite")
        )
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    // MARK: - Init
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    // MARK: - Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    /// When you cannot invoke a method from a Framework (UIKit) you want to test (e.g. framework limitation), move the logic
    /// to a method you can invoke like this
    
    func configureWindow() {
        //  let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        /// Not actual anymore since we comment EssentialAppUIAcceptanceTests
        //        let remoteClient = makeRemoteClient()
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    /// Not actual anymore since we comment EssentialAppUIAcceptanceTests
    //    func makeRemoteClient() -> HTTPClient {
    //        return httpClient
    //    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        remoteFeedLoader
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}


extension RemoteLoader: FeedLoader where R == [FeedImage] {}
    
//public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
//
//public extension RemoteImageCommentsLoader {
//    convenience init(url: URL, client: HTTPClient) {
//        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
//    }
//}

//
//public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>
//
//public extension RemoteFeedLoader {
//    convenience init(url: URL, client: HTTPClient) {
//        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
//    }
//}
