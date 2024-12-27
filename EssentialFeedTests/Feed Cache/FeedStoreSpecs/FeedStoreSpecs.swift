//
//  FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 23.11.2024.
//


import Foundation

/*
 Создание спецификаций для тестирования с использованием протокола FeedStoreSpecs и его производных (FailableRetrieveFeedStoreSpecs, FailableInsertFeedStoreSpecs, и т.д.) позволяет строго типизировать тестовые сценарии, разделять ответственность между различными аспектами функциональности и следовать принципам ISP (Interface Segregation Principle) и LSP (Liskov Substitution Principle). Давайте разберем причины такого подхода.
 */

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws

    func test_insert_deliversNoErrorOnEmptyCache() throws
    func test_insert_deliversNoErrorOnNonEmptyCache() throws
    func test_insert_overridesPreviouslyInsertedCacheValues() throws

    func test_delete_deliversNoErrorOnEmptyCache() throws
    func test_delete_hasNoSideEffectsOnEmptyCache() throws
    func test_delete_deliversNoErrorOnNonEmptyCache() throws
    func test_delete_emptiesPreviouslyInsertedCache() throws

    func test_storeSideEffects_runSerially() throws
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError() throws
    func test_retrieve_hasNoSideEffectsOnFailure() throws
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError() throws
    func test_insert_hasNoSideEffectsOnInsertionError() throws
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError() throws
    func test_delete_hasNoSideEffectsOnDeletionError() throws
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs


/*
 Зачем использовать спецификации через протоколы?
 Явное описание требований: Протокол FeedStoreSpecs определяет контракт (спецификацию), который каждая реализация хранилища должна соблюдать. Это гарантирует, что все реализации FeedStore (например, работающие с CoreData, InMemory или сетью) проходят через одинаковые тесты для базовых операций: retrieve, insert и delete.
 Избежание избыточной реализации (следование ISP): Вместо того чтобы создавать монолитный протокол, включающий методы для всех возможных ситуаций (например, ошибки), спецификации разделяются:
 Базовые тесты (FeedStoreSpecs) включают только функциональность, которую должны поддерживать все реализации.
 Тесты на обработку ошибок (FailableRetrieveFeedStoreSpecs, FailableInsertFeedStoreSpecs, FailableDeleteFeedStoreSpecs) добавляются только для тех реализаций, которые могут завершиться с ошибкой (например, файловые или сетевые хранилища).
 Это предотвращает ситуацию, в которой, например, InMemory-реализация хранилища вынуждена реализовывать ненужные тесты про обработку ошибок.
 Поддержка подстановки (следование LSP): Все спецификации с ошибками наследуются от FeedStoreSpecs. Это позволяет использовать любые реализации (например, InMemoryFeedStore, CodableFeedStore) в тестах для базовых методов, сохраняя корректность поведения. Таким образом, реализация может быть подставлена вместо абстракции, не нарушая логику работы.
 Почему тесты разделены на отдельные методы?
 Одна проверка на тест (single assertion per test): Разделение тестов на небольшие методы с одной проверкой делает их более читаемыми, упрощает поддержку и диагностику при сбоях. Например:
 Тест assertThatInsertDeliversErrorOnInsertionError проверяет только то, что операция вставки возвращает ошибку.
 Тест assertThatInsertHasNoSideEffectsOnInsertionError проверяет, что в случае ошибки хранилище остается в том же состоянии.
 Это позволяет выявлять точные причины сбоя без путаницы.
 Повышение читаемости и модульности: Использование расширений XCTestCase с методами для проверок (например, assertThatRetrieveDeliversEmptyOnEmptyCache) упрощает повторное использование кода для тестов и улучшает читабельность.
 Почему используется множественное наследование протоколов?
 Множественное наследование протоколов (например, typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs) позволяет:

 Композировать спецификации, не повторяя определения.
 Легко добавлять новые комбинации спецификаций.
 Пример: FailableFeedStoreSpecs — это объединение всех спецификаций с ошибками, что полезно для хранилищ, где любая операция может завершиться неудачей.

 В чем преимущество разделения спецификаций?
 Легкость тестирования: Новая реализация хранилища (например, InMemoryFeedStore) может быть протестирована только на соответствие базовым спецификациям FeedStoreSpecs, если она не предполагает ошибок.
 Модульность: Каждая спецификация изолирована, что упрощает добавление новых тестов или изменение существующих.
 Упрощение поддержки: Разделение позволяет быстрее находить проблемные области, т.к. тесты изолированы.
 Пример практического применения:
 Допустим, у нас есть InMemoryFeedStore, который никогда не завершает операции с ошибкой:

 Он должен реализовать только тесты из FeedStoreSpecs.
 Тесты из FailableRetrieveFeedStoreSpecs ему не нужны, что экономит время на реализацию и поддержание тестов.
 В то же время, для CodableFeedStore все спецификации (включая ошибки) применимы, т.к. операции могут завершиться неудачей (например, если файл поврежден).

 Итог:
 Создание спецификаций через протоколы позволяет:

 Строго формализовать поведение разных реализаций.
 Сохранять модульность, читабельность и простоту поддержки тестов.
 Следовать ключевым принципам проектирования (ISP и LSP).
 */
