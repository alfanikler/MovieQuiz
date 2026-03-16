//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Alfa on 16.03.2026.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuizStep(quiz step: QuizStepViewModel)
    func showGameResult()
    
    func showAnswerResult(isCorrectAnswer: Bool)
    func hideAnswerResult()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
