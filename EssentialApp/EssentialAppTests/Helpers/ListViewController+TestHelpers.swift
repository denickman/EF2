//
//  ListViewController+TestHelpers.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    
    var errorMessage: String? {
        return errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    override public func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        // to prevent loading cells ahead of time with diffable data source
        tableView.frame = CGRect.init(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
}

extension ListViewController {
    
    private var feedImagesSection: Int { 0 }
    private var feedLoadMoreSection: Int { 1 }
    
    func numberOfRenderedFeedImageViews() -> Int {
        /// tableView.reloadData does not force an immediate layout update
        /// 'didEndDisplayingCell' will only be called in the next layout cycle
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func simulateLoadMoreFeedAction() {
             guard let view = cell(row: 0, section: feedLoadMoreSection) else { return }

             let delegate = tableView.delegate
             let index = IndexPath(row: 0, section: feedLoadMoreSection)
             delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
         }
}

extension ListViewController {
    private var commentsSection: Int {
        .zero
    }
    
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel?.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel?.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel?.text
    }
 
    func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else { return nil }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
    
}


extension ListViewController {
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard tableView.numberOfSections > section,
              tableView.numberOfRows(inSection: section) > row else {
            return nil
        }
        let indexPath = IndexPath(row: row, section: section)
        return tableView.cellForRow(at: indexPath)
    }
}
