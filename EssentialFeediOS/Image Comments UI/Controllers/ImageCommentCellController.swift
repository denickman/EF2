//
//  ImageCommentCellController.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.01.2025.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController {
 
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
}

// MARK: - CellController

extension ImageCommentCellController: CellController {
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        
        return cell
    }

}
