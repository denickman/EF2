//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 10.11.2024.
//

import Foundation

public final class FeedItemsMapper {
    
    private struct Root: Decodable {
        
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable {
            public let id: UUID
            public let description: String?
            public let location: String?
            public let image: URL
        }
        
        var images: [FeedImage] {
            items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
            }
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
           throw RemoteFeedLoader.Error.invalidData
        }
        return root.images
    }
}






//public struct FeedItem: Decodable, Equatable {
//
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case description
//        case location
//        case imageURL = "image"
//    }
//
//    public let id: UUID
//    public let description: String?
//    public let location: String?
//    public let imageURL: URL
//
//    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
//        self.id = id
//        self.description = description
//        self.location = location
//        self.imageURL = imageURL
//    }
//}



/*
 Инкапсуляция структуры данных:
 В новой версии структуры Root и Item были сделаны private, а также добавлено соответствие между Item и FeedItem с помощью item как вычисляемого свойства.
 Это сделано для того, чтобы скрыть детали внутренней реализации RemoteFeedLoader и не позволить внешнему коду напрямую взаимодействовать с внутренними структурами данных. Внешний код теперь видит только FeedItem и не зависит от структуры JSON, что упрощает интерфейс и защищает от изменений в деталях реализации.
 Маппинг данных во внутренней модели Item:
 В новом варианте Item имеет структуру, более специфичную для JSON (например, images вместо imageURL), что позволяет точно описать JSON-ответ от сервера.
 Затем Item преобразуется в FeedItem через свойство item. Это позволяет изолировать код, преобразующий данные, так что JSON-данные могут изменяться, не затрагивая модель FeedItem и ее использование вне фреймворка.
 Изоляция логики декодирования:
 В новой версии JSON декодируется во Root, который содержит массив Item. После этого items.map { $0.item } преобразует каждый Item в FeedItem, создавая окончательный результат для клиента.
 Этот подход позволяет легко изменять JSON-формат или саму структуру модели данных сервера, не влияя на внешний интерфейс, предоставляемый фреймворком.
 Упрощение внешнего интерфейса:
 Пользователи фреймворка взаимодействуют только с FeedItem, не зная о существовании Root и Item. Это уменьшает объем информации, необходимой для работы с фреймворком, и позволяет фреймворку свободно развиваться без необходимости вносить изменения в интерфейс.
 Изолированность логики трансформации:
 Логика трансформации JSON в FeedItem теперь централизована в item внутри Item, и это делает тестирование проще, так как все преобразования находятся в одном месте.
 Таким образом, этот подход улучшает абстракцию и защищает архитектуру, делая структуру данных гибкой для будущих изменений и минимизируя влияние этих изменений на код, использующий RemoteFeedLoader.
 */
