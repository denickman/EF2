//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.11.2024.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentationError: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValueRepresentationError()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    

    /// #old version
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            
            /// Option 1
            //            if let error {
            //                completion(.failure(error))
            //            } else if let data = data, let response = response as? HTTPURLResponse {
            //                completion(.success((data, response)))
            //            }
            //            else {
            //                completion(.failure(UnexpectedValueRepresentationError()))
            //            }
            
            /// Option 2
            
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValueRepresentationError()
                }
            })
        }
        .resume()
    }
}
