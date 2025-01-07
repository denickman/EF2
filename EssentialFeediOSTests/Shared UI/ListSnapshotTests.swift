//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 05.01.2025.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {

    func test_emptyList() {
        let sut = makeSUT()
        sut.display(emptyList())
        
        // record
//                record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
//                record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
        
        // assert
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        // record
//                record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
//                record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
        
        // assert
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .medium)), named: "LIST_WITH_ERROR_MESSAGE_light")

    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
       
        let controller = ListViewController()
        controller.loadViewIfNeeded() // view is ready to be rendered
        controller.tableView.separatorStyle = .none
        
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        
        return controller
    }
    
    
    private func emptyList() -> [CellController] { [] }

}
