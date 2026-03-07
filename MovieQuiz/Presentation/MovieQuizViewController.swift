import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var isActionsEnabled = true {
        didSet {
            yesButton.isEnabled = isActionsEnabled
            noButton.isEnabled = isActionsEnabled
        }
    }

    private var questionFactory: QuestionFactoryProtocol?
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    
    private let questionsAmount = 10
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        let questionFactory = QuestionFactory()

        questionFactory.delegate = self

        self.questionFactory = questionFactory
        self.questionFactory?.requestNextQuestion()
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
            image: UIImage(named: model.image) ?? UIImage(),
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
    
    private func showResults() {
        let title = "Этот раунд окончен!"
        let text = "Ваш результат \(correctAnswers)/\(questionsAmount)"
        let buttonText = "Сыграть еще"

        let results = QuizResultsViewModel(
            title: title,
            text: text,
            buttonText: buttonText
        )

        let alert = UIAlertController(title: results.title, message: results.text, preferredStyle: .alert)

        let action = UIAlertAction(title: results.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }

            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
