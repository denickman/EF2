//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 22.11.2024.
//

import Foundation

public class CodableFeedStore: FeedStore {

    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, url: url)
        }
    }
    
    // MARK: - Properties
    
    private var storeURL: URL
    
    // a default init of DispatchQueue makes seriall queue (not concurrent)
    // .userInitiated qos - indicates the work is important for the user and should complete as soon as possible, but it still runs in the background.
    // The .userInitiated level does not run tasks on the main thread; instead, it executes them on a background thread but with higher priority than lower QoS levels (e.g., .utility or .background).
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    // MARK: - Init
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    // MARK: - Feed Store Protocol?
    
    // since -retrieve does not have side effects we can run it concurently
    public func retrieve(completion: @escaping RetrievalCompletion) {
        // value types are thread safe
        let storeURL = self.storeURL
        
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        // CodableFeedImage.init - reference to init of a structure
        // same result
        //        let cache = Cache(
        //            feed: feed.map { localImage in
        //                CodableFeedImage(localImage)
        //            },
        //            timestamp: timestamp
        //        )
        
        
        // for the operations that have side effects let`s use barrier flags (prevent race conditions)
        // barried put queue on hold until it`s done
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    // for the operations that have side effects let`s use barrier flags (prevent race conditions)

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
}
