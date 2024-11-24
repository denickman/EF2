//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Denis Yaremenko on 24.11.2024.
//

import XCTest
import EssentialFeed
/*
 
 Модульные тесты проверяют отдельные компоненты системы в изоляции.
 Интеграционные тесты проверяют, как компоненты системы взаимодействуют друг с другом.
 End-to-End тесты проверяют систему в целиком, как она работает от начала до конца с реальными пользовательскими сценариями.
 
 
 Что такое интеграционные тесты:
 Это тесты, которые проверяют взаимодействие между двумя или более компонентами приложения, без использования моков (mocks), стабов (stubs), шпионов (spies) или других тестовых двойников.
 Они гарантируют, что компоненты работают корректно в связке, используя реальные реализации (например, Core Data для хранения данных).
 
 Почему модульные тесты предпочтительнее в качестве основной стратегии:
 Быстрее: Тесты изолированных компонентов выполняются значительно быстрее, так как не включают внешние зависимости.
 Проще: Меньше настроек и зависимостей, упрощенная поддержка.
 Дешевле: Меньше времени на написание и выполнение, линейный рост сложности при добавлении новых тестов.
 Недостатки интеграционных тестов:
 Долгое выполнение: Используют реальную инфраструктуру (например, базы данных, сеть), что делает их медленными.
 Сложность и хрупкость: Тесты требуют большего объема подготовки и могут часто ломаться при малейших изменениях.
 Высокая стоимость: С увеличением числа состояний компонентов их количество растет экспоненциально, что увеличивает время выполнения и сложность написания.
 
 Идеальная пирамида тестирования (The Ideal Testing Pyramid):
 Основание пирамиды — модульные тесты (большинство тестов).
 Средний уровень — интеграционные тесты (ограниченное количество для проверки ключевых взаимодействий).
 Верхушка пирамиды — сквозные (end-to-end) тесты, покрывающие поведение системы через пользовательский интерфейс.
 
 
 Когда нужны интеграционные тесты:
 Проверка "счастливых путей" (happy paths) — основных сценариев использования.
 Убеждение в том, что разные компоненты (например, LocalFeedLoader и CoreDataFeedStore) корректно взаимодействуют.
 Проблемы, которые решаются интеграционными тестами:
 Избежание ошибок интеграции, которые могут быть упущены модульными тестами.
 Проверка реальных взаимодействий, чтобы удостовериться, что система работает в продакшн-среде.
 
 
 
 Когда писать интеграционные тесты:
 После завершения модульного тестирования.
 Для проверки реальных взаимодействий между основными компонентами.
 Пример подхода:
 Разработка LocalFeedLoader велась изолированно, через контракт (протокол FeedStore), чтобы избежать раннего выбора конкретного механизма хранения данных.
 После создания изолированных тестов была добавлена реальная реализация (CoreDataFeedStore) и проведено тестирование их взаимодействия с помощью интеграционных тестов.
 
 
 Рекомендации:
 Интеграционные тесты следует использовать как дополнение к модульным тестам, а не как основную стратегию.
 Фокус на модульных тестах обеспечивает скорость, надежность и низкую стоимость тестирования.
 Интеграционные тесты должны покрывать только ключевые сценарии, чтобы избежать лишней сложности.
 */

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        // test several instances that can handle the same cache data
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImagesFeed().models
        
        save(feed, with: sutToPerformSave)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        // override items using separate instances
        
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImagesFeed().models
        let latestFeed = uniqueImagesFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        // 'CodableFeedStore' in not suitable for our goal, so we prefer to use 'CoreDataFeedStore'
        //                 let store = CodableFeedStore(storeURL: storeURL)
        
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL()) 
    }
    
    // in integration tests we are using a real file system URL to save CoreData models
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
