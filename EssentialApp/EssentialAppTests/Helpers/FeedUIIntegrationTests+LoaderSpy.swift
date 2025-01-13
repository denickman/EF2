//
//  FeedUIIntegrationTests+LoaderSpy..swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    class LoaderSpy: FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        private var loadMoreRequest = [PassthroughSubject<Paginated<FeedImage>, Error>]()

        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        var loadMoreCallCount: Int {
            loadMoreRequest.count
        }
                
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
  
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
            
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequest.append(publisher)
                return publisher.eraseToAnyPublisher()
                
                
            }))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequest[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequest.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequest[index].send(completion: .failure(error))
        }
 
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
     
    }
    
}
