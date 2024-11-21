//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 20.11.2024.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        // local feed loader does not message store upon creation before loading the feed from the cache store
        let (store, _) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        // retrive the cache
        let (store, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_failsOnRetrievalError() {
        // fails when try to retrieve cache
        
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        // retrieve empty cache (sad cache)
        
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        // validate the cache is less then 7 days old?
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrievalWithFeed(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    
    func test_load_deliversNoImagesImagesOnSevenDaysOldCache() {
        // expired cache
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithFeed(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesImagesOnMoreThanSevenDaysOldCache() {
        // expired cache - no images on more then 7 days old cache
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithFeed(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        // when load feed we do not delete a cache (no side effects but got error)
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        // with no side effects
        // if cache is not invalid it should not be deleted
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }

    func test_load_hasNoSideEffectsOnLessThan7DaysOldCache() {
        // no side effects
        // do not delete cache if it less than 7 days old
        let (store, sut) = makeSUT()
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load { _ in }
        store.completeRetrievalWithFeed(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
        // no side effects
        // when get items from cache it should delete cache if more than 7 days old
        let (store, sut) = makeSUT()
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        
        sut.load { _ in }
        store.completeRetrievalWithFeed(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectsOnMoreThanSevenDaysOldCache() {
        // no side effects
        // when get items from cache it should delete cache if more than 7 days old
        let (store, sut) = makeSUT()
        
        let feed = uniqueImagesFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        sut.load { _ in }
        store.completeRetrievalWithFeed(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let exp = expectation(description: "Wait for load completion")
                
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
     
            case let (.success(expectedItems), .success(receivedItems)):
                XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                
            case let (.failure(expectedFailure as NSError), .failure(receivedFailure as NSError)):
                XCTAssertEqual(expectedFailure, receivedFailure, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}


