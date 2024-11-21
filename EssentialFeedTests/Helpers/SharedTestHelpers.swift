//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 21.11.2024.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "domain", code: 0)
}


func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
