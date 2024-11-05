//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import XCTest

class RemoteFeedLoader {
 
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "http://anyurl.com")
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
 
    func test_init_doesNotReqeustDataFromURL() {
        
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
 
