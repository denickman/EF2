//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    var presenter: LoadResourcePresenter<Resource, View>?
    
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    private var isLoading = false
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        presenter?.didStartLoading()
        isLoading = true
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel:  { [weak self] in
                self?.isLoading = false
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                    
                    self?.isLoading = false
                    
                }, receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                })
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
