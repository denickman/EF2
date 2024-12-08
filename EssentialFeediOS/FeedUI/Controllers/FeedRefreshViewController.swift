//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.12.2024.
//

import UIKit

final class FeedRefreshViewController {
    
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: FeedViewModel
    
    // MARK: - Init
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        view.beginRefreshing()
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
