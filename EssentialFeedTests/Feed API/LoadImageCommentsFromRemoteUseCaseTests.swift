//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 30.12.2024.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotReqeustDataFromURL() {
        let (client, _) = makeSut()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        
        let url = URL.init(string: "https://a-given-url.com")!
        let (client, sut) = makeSut(url: url)
        
        sut.load { _ in }
        
        XCTAssertFalse(client.requestedURLs.isEmpty)
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        
        let url = URL.init(string: "https://a-given-url.com")!
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
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        // check 199, 201, 300, 400, 500 statuses
        
        let (client, sut) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    // response 200 but invalid data
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, sut) = makeSut()
        expect(sut, toCompleteWithResult: failure(.invalidData), when: {
            let invalidJSON = Data("invalidJson".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
        let (client, sut) = makeSut()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJSON([]) // Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    // happy path
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (client, sut) = makeSut()

        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "description", location: "location", imageURL: URL(string: "https://another-url.com")!)
 
        let items = [item1.json, item2.json]
        
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let data = makeItemsJSON(items)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        
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
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, sut: RemoteImageCommentsLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
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
        _ sut: RemoteImageCommentsLoader,
        toCompleteWithResult expected: RemoteImageCommentsLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { received in
            switch (received, expected) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case (.failure(let receivedError as RemoteImageCommentsLoader.Error), .failure(let expectedError as RemoteImageCommentsLoader.Error)):
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
