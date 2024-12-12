//
//  UIImageView+Ext.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 11.12.2024.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        if newImage != nil {
            alpha = .zero
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        }
    }
}

