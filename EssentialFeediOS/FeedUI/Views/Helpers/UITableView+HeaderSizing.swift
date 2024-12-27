//
//  UITableView+HeaderSizing.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 23.12.2024.
//

import UIKit

extension UITableView {
    
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        /// Метод systemLayoutSizeFitting вычисляет размер заголовка с учетом его ограничений и текущих настроек автолэйаута. Параметр UIView.layoutFittingCompressedSize говорит системе, что нужно выбрать минимальный размер, который подходит для содержимого.
        ///  for example estimate height of multiline table view header
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        /// Сравнивается текущая высота заголовка (header.frame.height) с рассчитанным размером. Если высота отличается, это означает, что нужно обновить размер заголовка.
        let needsFrameUpdate = header.frame.height != size.height
        
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
    
}
