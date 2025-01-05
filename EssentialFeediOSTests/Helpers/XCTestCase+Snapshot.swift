//
//  XCTestCase+Snapshot.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.01.2025.
//

import XCTest

extension XCTestCase {
    
     func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        // load stored snapshot
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the 'record' method to store a snapshot before asserting,", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            // if we have a problem, we can store snapshot to check the possible distinctions
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
     func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        // write a created snapshot
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use 'assert' to compare the snapshot from now on.", file: file, line: line)
        } catch let error {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
     func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        // ../EssentialFeediOSTests/FeedSnapshotTests.swift
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent() // ../EssentialFeediOSTests/
            .appendingPathComponent("snapshots")  // ../EssentialFeediOSTests/snapshots
            .appendingPathComponent("\(name).png")  // ../EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        
    }
    
     func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return data
    }
}
