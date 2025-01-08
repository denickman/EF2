//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Denis Yaremenko on 08.01.2025.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
     func test_commentsView_hasTitle() {
        let (sut, _) = makeSUTT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsAction_requestCommentsFromLoader() {
        let (sut, loader) = makeSUTT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
                
        let (sut, loader) = makeSUTT()
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        sut.refreshControl?.beginRefreshing()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        sut.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        sut.refreshControl?.endRefreshing()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
        
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        RunLoop.current.run(until: Date() + 0.3)
        window.layoutIfNeeded()
        
        sut.beginAppearanceTransition(true, animated: false) // viewWillAppear
        sut.endAppearanceTransition() // viewIsAppearing + viewDidAppear
        //                XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        sut.refreshControl?.endRefreshing()
        sut.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    // Cells
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUTT()
        
        sut.loadViewIfNeeded()
        assertThatt(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThatt(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThatt(sut, isRendering: [comment0, comment1])
    }
    
     func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        // case when at first we have feeds models in feedvctrl,
        // then feed went away and didEndDisplaying may potentially crash after table view reload its data
        let comment = makeComment()
        
        let (sut, loader) = makeSUTT()
        sut.loadViewIfNeeded()
        assertThatt(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThatt(sut, isRendering: [comment])
        
        // load again but receive an empty image models
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThatt(sut, isRendering: [])
    }
  
     func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUTT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThatt(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThatt(sut, isRendering: [comment])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUTT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessages() {
        let (sut, loader) = makeSUTT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
  
    // MARK: - Helpers

    private func makeSUTT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
         ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    private func assertThatt(
        _ sut: ListViewController,
        isRendering comments: [ImageComment],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { (index,  comment) in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "usernmane at \(index)", file: file, line: line)

        }
        
    }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
    

