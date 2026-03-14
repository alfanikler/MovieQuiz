import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var isActionsEnabled = true {
        didSet {
            yesButton.isEnabled = isActionsEnabled
            noButton.isEnabled = isActionsEnabled
        }
    }

    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var alertPresenter = AlertPresenter()
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    
    private let questionsAmount = 10
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        let moviesLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)

        self.questionFactory = questionFactory
        self.questionFactory?.loadData()
        self.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        
        show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }

        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }

        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz: QuizStepViewModel) {
        imageView.image = quiz.image
        textLabel.text = quiz.question
        counterLabel.text = quiz.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        showQuestionImageBorder(color: borderColor)
        isActionsEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.hideQuestionImageBorder()
            self.showNextQuestionOrResults()

            self.isActionsEnabled = true
        }
    }
    
    private func showQuestionImageBorder(color: CGColor) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color
    }
    
    private func hideQuestionImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
            return
        }
        
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    private func restartQuiz() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showResults() {
        let gameResult = GameResult(
            correct: correctAnswers,
            total: questionsAmount,
            date: Date()
        )

        statisticService.store(gameResult)

        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: buildResultMessage(gameResult: gameResult),
            buttonText: "Сыграть еще раз"
        ) { [weak self] in
            self?.restartQuiz()
        }
        
        alertPresenter.show(in: self, model: alertModel)
    }
    
    private func buildResultMessage(gameResult: GameResult) -> String {
        let bestGame = statisticService.bestGame
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGameDate = bestGame.date.dateTimeString
        let gamesCount = statisticService.gamesCount

        let currentResultString = "Ваш результат: \(gameResult.correct)/\(gameResult.total)\n"
        let totalGamesCountString = "Количество сыгранных квизов: \(gamesCount)\n"
        let bestResultString = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))\n"
        let totalAccuracyString = "Средняя точность: \(totalAccuracy)%\n"
        
        return currentResultString + totalGamesCountString + bestResultString + totalAccuracyString
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) {
            print("Ok")
        }
        
        alertPresenter.show(in: self, model: alertModel)
    }
}
