import UIKit

private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

private struct QuizQuestionViewModel {
    let image: UIImage
    let question: String
    
    static func from(_ quizQuestion: QuizQuestion) -> Self {
        QuizQuestionViewModel(
            image: UIImage(named: quizQuestion.image) ?? UIImage(),
            question: quizQuestion.text
        )
    }
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0 {
        didSet {
            showQuestion(QuizQuestionViewModel.from(currentQuestion))
        }
    }
    
    private var currentQuestionNumber: String {
        "\(currentQuestionIndex + 1)/\(questions.count)"
    }
    
    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }

    private var correctAnswers = 0
    
    // MARK: - Mocks
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20

        // Нужно чтобы отработал didSet на currentQuestionIndex
        currentQuestionIndex = 0
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    private func showQuestion(_ questionViewModel: QuizQuestionViewModel) {
        imageView.image = questionViewModel.image
        textLabel.text = questionViewModel.question

        counterLabel.text = currentQuestionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        showQuestionImageBorder(color: borderColor)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideQuestionImageBorder()
            self.showNextQuestionOrResults()
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
        if currentQuestionIndex == questions.count - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
        }
    }
    
    private func showResults() {
        let results = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: "Ваш результат \(correctAnswers)/\(questions.count)",
            buttonText: "Сыграть еще"
        )

        let alert = UIAlertController(title: results.title, message: results.text, preferredStyle: .alert)

        let action = UIAlertAction(title: results.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
