//
//  UIControl+TestHelpers.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
