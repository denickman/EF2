//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

import EssentialFeed
import EssentialFeediOS
import Combine
import Foundation

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    // MARK: - Properties
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    // MARK: - Init
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                    }
                    
                }, receiveValue: { [weak self] data in
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
