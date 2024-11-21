//
//  FeedCacheTestHelpersFile.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 21.11.2024.
//

import Foundation
import EssentialFeed


func uniqueImage() -> FeedImage {
    .init(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImagesFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    
    let local = models.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    
    return (models, local)
}


func anyData() -> Data {
    Data("any data".utf8)
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
