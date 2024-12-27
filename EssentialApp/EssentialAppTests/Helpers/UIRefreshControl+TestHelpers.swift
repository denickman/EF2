//
//  UIRefreshControl+TestHelpers.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
