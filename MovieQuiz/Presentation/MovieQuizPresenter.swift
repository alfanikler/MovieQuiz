//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alfa on 16.03.2026.
//

import Foundation

final class MovieQuizPresenter {
    private weak var vc: MovieQuizViewControllerProtocol?

    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()

    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    init(viewController vc: MovieQuizViewControllerProtocol) {
        self.vc = vc
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            vc?.showGameResult()
            return
        }
        
        switchToNextQuestion()
        questionFactory.requestNextQuestion()
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        
        let isCorrect = currentQuestion.correctAnswer == isYes
        
        if isCorrect { correctAnswers += 1 }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        guard let vc else { return }

        vc.showAnswerResult(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self, let vc = self.vc else { return }

            self.proceedToNextQuestionOrResults()
            vc.hideAnswerResult()
        }
    }
    
    private func buildResultMessage(gameResult: GameResult) -> String {
        let bestGame = statisticService.bestGame
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGameDate = bestGame.date.dateTimeString
        let gamesCount = statisticService.gamesCount
        
        return """
        Ваш результат: \(gameResult.correct)/\(gameResult.total)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))
        Средняя точность: \(totalAccuracy)%
        """
    }
}

// MARK: - Public
extension MovieQuizPresenter {
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0

        questionFactory.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didTapYesButton() {
        didAnswer(isYes: true)
    }
    
    func didTapNoButton() {
        didAnswer(isYes: false)
    }
    
    func storeResult(_ gameResult: GameResult) {
        statisticService.store(gameResult)
    }
    
    func loadData() {
        questionFactory.loadData()
        vc?.showLoadingIndicator()
    }
    
    func createGameResult() -> GameResult {
        GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
    }
    
    func convertGameResultToAlertModel(_ gameResult: GameResult) -> AlertModel {
        let title = "Этот раунд окончен!"
        let message = buildResultMessage(gameResult: gameResult)
        let buttonText = "Сыграть еще раз"

        return AlertModel(
            title: title,
            message: message,
            buttonText: buttonText
        ) { [weak self] in
            self?.restartGame()
        }
    }
    
    func convertQuizQuestionToViewModel(model: QuizQuestion) -> QuizStepViewModel {
        let image = model.imageData
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        return QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )
    }
    
    func createNetworkErrorAlertModel(message: String) -> AlertModel {
        AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            self?.loadData()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        vc?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        vc?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        let viewModel = convertQuizQuestionToViewModel(model: question)
        
        currentQuestion = question
        
        DispatchQueue.main.async { [weak self] in
            self?.vc?.showQuizStep(quiz: viewModel)
        }
    }
}
