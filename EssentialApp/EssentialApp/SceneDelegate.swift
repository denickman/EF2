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
import os

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
        do {
            return try CoreDataFeedStore(storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.squlite")
            )
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var logger = Logger(subsystem: "your bundle ID here", category: "main")
    
    
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
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }.map(makePage)
            .delay(for: 2, scheduler: DispatchQueue.main)
        //            .flatMap { _ in
        //                Fail(error: NSError())
        //            }
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        //        let client = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, logger] in
                var startTime = CACurrentMediaTime()
                return httpClient
                    .getPublisher(url: url)
                    .logErrors(url: url, logger: logger)
                    .logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}


// do not need this logger is we use a combine approach
private class HTTPClientProfilingDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed.HTTPClientTask {
        logger.trace("Start loading url: \(url)")
        
        let startTime = CACurrentMediaTime()
        
        return decoratee.get(from: url) { [logger] result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finish loading url: \(url) in \(elapsed) seconds")
            completion(result)
        }
    }
}

extension Publisher {
    
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache missed for url: \(url)")
            }
        })
        .eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()

        return handleEvents(receiveSubscription: {  _ in
            logger.trace("Started loading url: \(url)")
            startTime = CACurrentMediaTime()
        }, receiveCompletion: { result in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finish loading url: \(url) in \(elapsed) seconds")
        })
        .eraseToAnyPublisher()
    }
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
            }
        })
        .eraseToAnyPublisher()
    }
}
