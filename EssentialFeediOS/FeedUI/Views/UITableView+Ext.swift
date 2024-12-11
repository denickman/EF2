//
//  UITableView+Ext.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 11.12.2024.
//

import UIKit


extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let id = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: id) as! T
    }
}
