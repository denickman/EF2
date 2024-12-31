//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 31.12.2024.
//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotReqeustDataFromURL() {
        let (client, _) = makeSut()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (client, sut) = makeSut(url: url)
        
        sut.load { _ in }
        
        XCTAssertFalse(client.requestedURLs.isEmpty)
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (client, sut) = makeSut(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // when http client fails we have some connectivity issue
        let (client, sut) = makeSut()
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "text", code: 0)
            client.complete(with: clientError)
        }
    }
    
    // response 200 but invalid data
    func test_load_deliversErrorOnMapperError() {
        let (client, sut) = makeSut(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompleteWithResult: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: anyData())
        })
    }
    
    // happy path
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        
        let (client, sut) = makeSut(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toCompleteWithResult: .success(resource), when: {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in
            "any"
        })
        
        var capturedResults = [RemoteLoader<String>.Result]()
        
        sut?.load {
            capturedResults.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        url: URL = URL(string: "https://any-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteLoader<String>) {
        let client = HTTPClientSpy()
        
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String : Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        _ sut: RemoteLoader<String>,
        toCompleteWithResult expected: RemoteLoader<String>.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { received in
            switch (received, expected) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case (.failure(let receivedError as RemoteLoader<String>.Error), .failure(let expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expected) got \(received) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
