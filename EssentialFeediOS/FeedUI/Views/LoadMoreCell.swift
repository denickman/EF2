//
//  LoadMoreCell.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 11.01.2025.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
    
    public var isLoading: Bool {
        get {
            spinner.isAnimating
        }
        
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])
        
        return spinner
    }()
}
