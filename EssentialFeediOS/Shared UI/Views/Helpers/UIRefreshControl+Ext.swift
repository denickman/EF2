//
//  UIRefreshControl+Ext.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.12.2024.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
