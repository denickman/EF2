//
//  FeedSnapshotTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 23.12.2024.
//

import XCTest
import EssentialApp
import EssentialFeediOS

class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())
        let snapshot = sut.snapshot()
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    
    // MARK: - Helpers
    
    func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded() // view is ready to be rendered
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        // ../EssentialFeediOSTests/FeedSnapshotTests.swift

        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent() // ../EssentialFeediOSTests/
            .appendingPathComponent("snapshots")  // ../EssentialFeediOSTests/snapshots
            .appendingPathComponent("\(name).png")  // ../EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch let error {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}


extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
