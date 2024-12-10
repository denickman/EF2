//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.12.2024.
//

import UIKit
/*
 1. Разделение ответственности и инкапсуляция
 FeedRefreshViewController отвечает исключительно за отображение и управление состоянием обновления (показ/скрытие индикатора загрузки), в то время как логика получения данных (загрузка фида) находится в другом компоненте — FeedPresenter.

 Вместо того чтобы передавать сам presenter, передается только метод loadFeed, который будет вызываться при необходимости обновить данные. Такой подход помогает избежать сильной связи между FeedRefreshViewController и FeedPresenter, что делает код более модульным и облегчает тестирование.
 
 2. Принцип инъекции зависимостей
 Когда вы передаете метод (loadFeed) вместо целого объекта (presenter), вы инкапсулируете логику в FeedPresenter, а FeedRefreshViewController получает только тот функционал, который ему необходим, без лишних зависимостей.

 Передача функции через инициализатор (init(loadFeed:)) — это частный случай инъекции зависимостей, при которой класс получает свою зависимость не через прямое создание или установку объектов, а через параметры конструктора. Это позволяет более гибко управлять зависимостями и тестировать компоненты в изоляции.
 
 3. Снижение связности компонентов
 FeedPresenter знает, как загружать данные, а FeedRefreshViewController только отображает индикатор загрузки.
 FeedViewController (или любой другой класс, который будет использовать FeedRefreshViewController) может решить, каким образом загрузить фид: это может быть вызов метода из FeedPresenter или любой другой логики, которая соответствует бизнес-правилам.
 Такой подход помогает соблюдать принцип единственной ответственности: каждый компонент делает только то, что ему предназначено.
 
 4. Тестируемость
 Этот подход также способствует легкости тестирования:

 Вы можете тестировать FeedRefreshViewController, передавая ему различные реализации функции loadFeed (например, мок-функции для тестов), и проверять, как он ведет себя при разных состояниях загрузки.
 Это позволяет тестировать логику обновления данных (loadFeed) независимо от FeedRefreshViewController, и наоборот, что упрощает юнит-тестирование.
 5. Использование замыканий (closures)
 Передача функции через замыкания (loadFeed: @escaping () -> Void) позволяет избежать жесткой привязки к объектам. Вместо того чтобы передавать прямую ссылку на объект, можно передать только нужную часть функционала, которая будет вызвана позже, что увеличивает гибкость и уменьшает зависимость между объектами.
 */

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: FeedLoadingView {

    private(set) lazy var view = loadView()
    private let delegate: FeedRefreshViewControllerDelegate
    
    // MARK: - Init
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing() 
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
