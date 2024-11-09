//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 07.11.2024.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                
                do {
                   let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }

            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


private class FeedItemsMapper {
    
    private struct Root: Decodable {
        public let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
             FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return try root.items.map { $0.item }
    }
}




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
