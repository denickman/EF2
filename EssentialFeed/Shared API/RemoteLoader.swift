//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 31.12.2024.
//

//import Foundation
//
//public final class RemoteLoader<R> { // R - resource
// 
//    public enum Error: Swift.Error {
//        case connectivity
//        case invalidData
//    }
//    
//    public typealias Result = Swift.Result<R, Swift.Error>
//    public typealias Mapper = (Data, HTTPURLResponse) throws -> R // R - Resource
//
//    private let url: URL
//    private let client: HTTPClient
//    private let mapper: Mapper
//    
//    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
//        self.client = client
//        self.url = url
//        self.mapper = mapper
//    }
//    
//    public func load(completion: @escaping (Result) -> Void) {
//        client.get(from: url) { [weak self] result in
//            guard let self else { return }
//           
//            switch result {
//            case let .success(data, response):
//                completion(self.map(data, response: response))
//                
//            case .failure:
//                completion(.failure(Error.connectivity))
//            }
//        }
//    }
//    
//    private func map(_ data: Data, response: HTTPURLResponse) -> Result {
//        do {
//            return .success(try mapper(data, response))
//        } catch (let error) {
//            return .failure(Error.invalidData)
//        }
//    }
//}
