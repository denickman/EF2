//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 04.12.2024.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    // MARK: - Properties
    
    private(set) public var errorView = ErrorView()
    public var onRefresh: (() -> Void)?
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, ctrl in
            ctrl.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        refresh()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .left
        tableView.dataSource = dataSource
        tableView.tableHeaderView = errorView.makeContainer()

        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ sections: [CellController]...) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }
        
//        if #available(iOS 15.0, *) {
//            dataSource.applySnapshotUsingReloadData(snapshot)
//        } else {
            dataSource.apply(snapshot)
//        }
        /// Also there are 3 commits that should be implemented for new version of animating
        /// iOS 15 Update #1 iOS 15 Update #2 iOS 15 Update 3 iOS 15 Update 4
        /// https://academy.essentialdeveloper.com/courses/447455/lectures/24569943
    }
    
    // MARK: - TableView Delegate
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    ///////
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          let dl = cellController(at: indexPath)?.delegate
          dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
      }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dlp = cellController(at: indexPath)?.dataSourcePrefetching
            dlp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dlp = cellController(at: indexPath)?.dataSourcePrefetching
            dlp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    
    
}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}
