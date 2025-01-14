//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.01.2025.
//


public struct Paginated<Item> {
//  public typealias LoadMoreCompletion = (Result<Paginated<Item>, Error>) -> Void same as ->
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void

         public let items: [Item]
         public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?

         public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
             self.items = items
             self.loadMore = loadMore
         }
}
