//
//  UIButton+TestHelpers.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 22.12.2024.
//


import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
