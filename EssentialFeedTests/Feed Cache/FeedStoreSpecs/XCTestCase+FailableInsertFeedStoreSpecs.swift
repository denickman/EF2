
//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 23.11.2024.
//


import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImagesFeed().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImagesFeed().local, Date()), to: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
