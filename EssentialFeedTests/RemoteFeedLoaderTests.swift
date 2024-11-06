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
    private let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
 
    func load() {
        client.get(from: url)
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
    
    func makeSut() -> (client: HTTPClientSpy, sut: RemoteFeedLoader) {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (client, sut)
    }
    
}
 
