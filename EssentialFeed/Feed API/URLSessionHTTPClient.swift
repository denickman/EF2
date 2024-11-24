//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 13.11.2024.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentationError: Error {}
    
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
