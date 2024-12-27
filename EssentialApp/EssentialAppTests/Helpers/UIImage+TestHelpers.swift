//
//  UIImage+TestHelpers.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

/*
 *iOS 16.1 Update*
 On iOS 16.1, comparing images generated with the UIImage.make(color:) helper started to fail due to differences in the image scale when converting it to pngData. To prevent this issue, you need to update the UIImage.make(color:) helper implementation to set a fixed scale of 1.
 
 */

extension UIImage {
    static func makeOldVersion(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}


