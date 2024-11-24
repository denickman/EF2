//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 22.11.2024.
//


/*
 Предпочтение между `CodableFeedStore` и `CoreDataFeedStore` зависит от нескольких факторов, включая требования к производительности, гибкости, удобству использования и типу данных. Рассмотрим основные преимущества использования `CoreDataFeedStore` по сравнению с `CodableFeedStore`.

 ### 1. **Производительность и масштабируемость**
    - **CoreDataFeedStore** использует **Core Data**, который оптимизирован для работы с большими объемами данных и является высокоэффективным механизмом для хранения, поиска и манипуляции данными в приложении.
    - В случае с большими объемами данных, **Core Data** будет работать быстрее и эффективнее, чем простой файл, как в `CodableFeedStore`. Это связано с тем, что Core Data использует индексирование и другие методы оптимизации запросов.
    
 ### 2. **Поддержка запросов и фильтрации**
    - В **Core Data** можно легко создавать сложные запросы для извлечения данных с использованием `NSFetchRequest`, включая фильтрацию, сортировку и агрегацию.
    - В `CodableFeedStore` вам нужно вручную извлекать и обрабатывать данные (например, читать и парсить JSON), что делает его менее гибким для сложных операций над данными.

 ### 3. **Транзакции и управление изменениями**
    - **Core Data** поддерживает транзакции, что позволяет безопасно управлять изменениями данных. Например, вы можете вставить, обновить или удалить записи внутри одной транзакции, что обеспечит целостность данных.
    - В `CodableFeedStore`, при каждом изменении файла, вам нужно вручную обрабатывать ошибки и состояния, такие как корректная запись данных в файл или удаление. Транзакции и блокировки для предотвращения состояний гонки (race conditions) — это дополнительная логика.

 ### 4. **Управление памятью**
    - **Core Data** имеет встроенное управление памятью через механизмы отслеживания объектов в контексте. Это позволяет эффективно работать с большим количеством объектов, не перегружая память.
    - В `CodableFeedStore` все данные загружаются в память в виде целого объекта, что может быть проблемой при большом объеме данных.

 ### 5. **Миграции и обновления схемы данных**
    - **Core Data** предоставляет мощные инструменты для миграции данных при изменении модели данных, что очень полезно в приложениях, где требуется менять структуру данных в процессе разработки.
    - В `CodableFeedStore` миграция данных будет сложной и потребует вручную написанных механизмов для старых и новых версий данных.

 ### 6. **Поддержка многозадачности и потоков**
    - **Core Data** отлично работает с многозадачностью и многопоточностью, что важно при работе с большими объемами данных. Контексты данных (`NSManagedObjectContext`) можно использовать в фоновом режиме, что обеспечивает безопасную работу с данными в многозадачных приложениях.
    - В `CodableFeedStore` все операции выполняются на одном потоке, и при необходимости работы с несколькими потоками потребуется вручную управлять синхронизацией.

 ### 7. **Гибкость**
    - **Core Data** предлагает широкие возможности для расширения и адаптации: можно использовать отношения между объектами, связи «один ко многим», «многие ко многим», и т. д. Это делает его мощным инструментом для более сложных моделей данных.
    - В `CodableFeedStore` данные представлены как простые структуры, и если структура данных изменится, вам придется вручную адаптировать логику кодирования и декодирования.

 ### 8. **Поддержка мультимедийных данных**
    - **Core Data** может эффективно работать с большими объектами данных, такими как изображения или другие бинарные данные, через атрибуты типа `Binary Data`. Это позволяет хранить и извлекать такие объекты без необходимости дополнительных манипуляций с файлами.
    - В `CodableFeedStore` вам нужно будет самим управлять такими данными, что делает работу с мультимедиа менее удобной.

 ### Заключение:
 `CoreDataFeedStore` предпочтительнее, если вам нужны:
 - Более сложные операции с данными, такие как фильтрация, поиск, сортировка.
 - Поддержка больших объемов данных с возможностью их оптимизированного хранения.
 - Простота управления изменениями и миграцией данных.
 - Гибкость в управлении отношениями между объектами данных.
 - Эффективная работа с многозадачностью и многими потоками.

 Если ваши требования к хранилищу данных достаточно просты, и вам нужно просто сохранять небольшие объекты с возможностью их сериализации и десериализации, `CodableFeedStore` может быть хорошим выбором. Однако для более сложных приложений с большими объемами данных и высокими требованиями к производительности и гибкости, **CoreDataFeedStore** будет намного более эффективным и удобным решением.
 */



import Foundation

public final class CodableFeedStore: FeedStore {

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
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
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
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // for the operations that have side effects let`s use barrier flags (prevent race conditions)

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
