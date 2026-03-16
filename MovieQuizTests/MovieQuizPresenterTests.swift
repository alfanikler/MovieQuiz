//
//  MovieQuizPresenterTests.swift
//  MovieQuiz
//
//  Created by Alfa on 16.03.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showQuizStep(quiz: QuizStepViewModel) {}
    func showGameResult() {}
    func showAnswerResult(isCorrectAnswer: Bool) {}
    func hideAnswerResult() {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let expectedQuestionText = "Question Text"
        let expectedQuestionNumberText = "1/10"

        let emptyData = Data()
        let question = QuizQuestion(imageData: emptyData, text: expectedQuestionText, correctAnswer: true)
        let viewModel = sut.convertQuizQuestionToViewModel(model: question)

        XCTAssertEqual(viewModel.question, expectedQuestionText)
        XCTAssertEqual(viewModel.questionNumber, expectedQuestionNumberText)
    }
}
