//
//  FeedImageCellController.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.12.2024.
//

import EssentialFeed
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
    
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let selection: () -> Void
    private var isLoading = false
    
    public init(
        viewModel: FeedImageViewModel,
        delegate: FeedImageCellControllerDelegate,
        selection: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.selection = selection
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = delegate.didRequestImage
        
        /// accessibilityIdentifier 'feed-image-cell' for EssentialAppUIAcceptanceTests
        cell?.accessibilityIdentifier = "feed-image-cell"
        /// accessibilityIdentifier 'feed-image' for EssentialAppUIAcceptanceTests
        cell?.feedImageView.accessibilityIdentifier = "feed-image"
        
        delegate.didRequestImage()
        return cell!
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
}

// MARK: - CellController

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        
        delegate.didRequestImage()
        
        
        /// accessibilityIdentifier 'feed-image-cell' for EssentialAppUIAcceptanceTests
        cell?.accessibilityIdentifier = "feed-image-cell"
        /// accessibilityIdentifier 'feed-image' for EssentialAppUIAcceptanceTests
        cell?.feedImageView.accessibilityIdentifier = "feed-image"
        
        return cell!
    }
    
    // this method will be called only when cell is going to be rendered on visible screen
    // if you do not have a good estimated cell size you can add logic to this method
    //    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        delegate.didRequestImage()
    //    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        delegate.didRequestImage()
        
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
    
}

// MARK: - ResourceView, ResourceLoadingView, ResourceErrorVie

extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    
    // MARK: - ResourceView Protocol
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    // MARK: - ResourceLoadingView
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    // MARK: - ResourceErrorView
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
    
}
