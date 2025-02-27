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

public final class FeedImageCellController: FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        /// accessibilityIdentifier 'feed-image-cell' for EssentialAppUIAcceptanceTests
        self.cell?.accessibilityIdentifier = "feed-image-cell"

        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        /// accessibilityIdentifier 'feed-image' for EssentialAppUIAcceptanceTests
        cell?.feedImageView.accessibilityIdentifier = "feed-image"
        cell?.feedImageView.image = viewModel.image
        
        cell?.feedImageView.setImageAnimated(viewModel.image)
        
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}

