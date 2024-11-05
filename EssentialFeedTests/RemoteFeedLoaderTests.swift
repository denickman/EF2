//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//


import XCTest


class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
 
    func test_init_doesNotReqeustDataFromURL() {
        
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
}
 
