import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setupPresenterAndLoadData()
    }
    
    // MARK: - Actions

    @IBAction private func didTapYesButton(_ sender: UIButton) {
        presenter.didTapYesButton()
    }
    
    @IBAction private func didTapNoButton(_ sender: UIButton) {
        presenter.didTapNoButton()
    }
    
    // MARK: - Setup
    
    private func configureUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    private func setupPresenterAndLoadData() {
        presenter = MovieQuizPresenter(viewController: self)
        presenter.loadData()
    }
    
    // MARK: - Other logic
    
    private func showQuestionImageBorder(isCorrectAnswer: Bool) {
        let color = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color
    }
    
    private func hideQuestionImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func toggleButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

// MARK: - MovieQuizViewControllerProtocol
extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func showQuizStep(quiz: QuizStepViewModel) {
        imageView.image = UIImage(data: quiz.image) ?? UIImage()
        textLabel.text = quiz.question
        counterLabel.text = quiz.questionNumber
    }
    
    func showGameResult() {
        let gameResult = presenter.createGameResult()
        let alertModel = presenter.convertGameResultToAlertModel(gameResult)

        presenter.storeResult(gameResult)
        alertPresenter.show(in: self, model: alertModel)
    }
    
    func showAnswerResult(isCorrectAnswer: Bool) {
        showQuestionImageBorder(isCorrectAnswer: isCorrectAnswer)
        toggleButtonsEnabled(false)
    }
    
    func hideAnswerResult() {
        hideQuestionImageBorder()
        toggleButtonsEnabled(true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        toggleButtonsEnabled(false)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()

        toggleButtonsEnabled(true)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = presenter.createNetworkErrorAlertModel(message: message)
        
        alertPresenter.show(in: self, model: alertModel)
    }
}
