//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 10.11.2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for response")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
        }
        
        // here is causing the race condition because teadDown works on main thread, while this request works on background
        makeSUT().get(from: url) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0) // with 1 does not work
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as NSError?

        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
                 XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
                 XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
                 XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
                 XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
                 XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
                 XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
                 XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
                 XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
             let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

             XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
         }
    
    func test_getFromURL_failsOnAllNilValues() {
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        let exp = expectation(description: "Wait for request")

        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp])
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        // given
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        // when
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
        
        // then
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    

    // scenario when url protocol system replace a data with a zero bytes
    // XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        // given
        let response = anyHTTPURLResponse()
        
        // when
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        // then
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
     
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
                 configuration.protocolClasses = [URLProtocolStub.self]
                 let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
             let result = resultFor(values, file: file, line: line)

        switch result {
        case let .success(data, response):
            return (data, response)
            
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {
             let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case .failure(let error):
            return error
            
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
             values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
            
            let sut = makeSUT(file: file, line: line)
            let exp = expectation(description: "Wait for request")
            
        var receivedResult: HTTPClient.Result!

        taskHandler(sut.get(from: anyURL()) { result in
                     receivedResult = result
                     exp.fulfill()
                 })
            
            wait(for: [exp])
            return receivedResult
    }
 
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

}
