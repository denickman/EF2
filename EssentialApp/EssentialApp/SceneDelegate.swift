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
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
        feedLoader: makeRemoteFeedLoaderWithLocalFallback,
        imageLoader: makeLocalImageLoaderWithRemoteFallback,
        selection: showComments  // the same as selection: { image in showComments(for: image) }
    ))
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
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
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {

        let remoteURL = baseURL.appendingPathComponent("/v1/feed")
        
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map {
                Paginated(items: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
//            .delay(for: 2, scheduler: DispatchQueue.main)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
