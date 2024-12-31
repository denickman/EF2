//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 30.12.2024.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
