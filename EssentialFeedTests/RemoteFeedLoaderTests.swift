//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 05.11.2024.
//

import XCTest


protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
 
    func load() {
        client.get(from: URL(string: "https://any-url.com")!)
    }
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
 
    func test_init_doesNotReqeustDataFromURL() {
        let (client, _) = makeSut()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let (client, sut) = makeSut()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    func makeSut() -> (client: HTTPClient, sut: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        return (client, sut)
    }
    
}
 
