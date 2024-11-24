//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 23.11.2024.
//


import XCTest
import EssentialFeed

// In finality we delete this coredatafeedstore tests

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() throws {
        let sut = try makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() throws {
        let sut = try makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}

/*
 Using /dev/null as the file URL in Core Data testing is a technique to create a Core Data persistent store that effectively discards all data, ensuring that no actual data is written to the disk. Here's why this technique is used and what it accomplishes:

 What is /dev/null?
 /dev/null is a special file in Unix-like systems that acts as a "black hole." Any data written to /dev/null is discarded, and reading from it immediately returns an end-of-file (EOF). It is often used as a sink for unwanted output.

 Why use /dev/null in Core Data testing?
 In-memory-like behavior:
 When you specify /dev/null as the store URL, Core Data creates a SQLite database-backed store but writes all the data to /dev/null, effectively discarding it. This is useful for testing because:
 It avoids polluting the disk with temporary test data.
 It simulates a persistent store without actual persistence.
 Separation from disk-based storage:
 Testing with /dev/null ensures that your tests do not interfere with real data stored on disk or with other tests that might be writing to the same location.
 Controlled environment:
 By discarding all data, you ensure that each test starts with a clean slate. You don't need to worry about cleaning up test data or initializing a separate in-memory store explicitly.
 Performance:
 Since no actual I/O happens (beyond the system-level handling of /dev/null), the tests can execute faster compared to writing to disk.
 */
