//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 21.11.2024.
//

import Foundation

// FeedCachePolicy a pure type with no side effects
// can be moved in any module in further

final class FeedCachePolicy {
    
    // in order to not instantiate a type of this class we create a private init here
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }
    
    // since this class does not have any state we make the method static
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge // date - time is right now
    }
}
