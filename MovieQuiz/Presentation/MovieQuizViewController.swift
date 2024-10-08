import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    var currentQuestion: QuizQuestion?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Variables
    private var presenter = MovieQuizPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenter?
    var currentTime: Date?
    var recordCorrectAnswers = 0
    var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewControllerProtocol = self
        presenter.showAnswerResults = {[weak self] isCorrect in self?.showAnswerResults(isCorrect: isCorrect) }
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self, statisticService: statisticService)
        
        presenter.viewDidLoad()
    }
    
    func configureButtons() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
    }
    
    func didTapOfButtons (_ isEnabled: Bool) {
        presenter.didTapOfButtons(isEnabled, noButton: noButton, yesButton: yesButton)
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator(isLoading: false)
        presenter.requestNextQuestionAndUpdateUI()
    }
    
    func didFailToLoadData(with error: Error) {
        presenter.showNetworkError(message: error.localizedDescription)
    }
    
    func showLoadingIndicator(isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }
    
    func restartQuiz() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        presenter.requestNextQuestionAndUpdateUI()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        didTapOfButtons(false)
        presenter.noButton(sender)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        didTapOfButtons(false)
        presenter.yesButton(sender)
    }
    func showAlert(title: String, message: String) {
    }
}
