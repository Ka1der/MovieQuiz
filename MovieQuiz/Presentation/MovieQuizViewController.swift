import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
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
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    var currentQuestion: QuizQuestion?
    var currentTime: Date?
    var recordCorrectAnswers = 0
    var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        presenter.showAnswerResults = {[weak self] isCorrect in self?.showAnswerResults(isCorrect: isCorrect) }
        //presenter = MovieQuizPresenter()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self, statisticService: statisticService)
        
        requestNextQuestionAndUpdateUI()
        configureButtons()
        showLoadingIndicator(isLoading: true)
        questionFactory?.loadData()
    }
    
    private func configureButtons() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
    }
    
    private func onOffButtons (_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator(isLoading: false)
        requestNextQuestionAndUpdateUI()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator(isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
   
    private func showNetworkError(message: String) {
        showLoadingIndicator(isLoading: false)
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.correctAnswers = 0
            if let question = self.questionFactory?.requestNextQuestion() {
                self.didReceiveNextQuestion(question: question)
            } else {
                self.showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            }
        }
        
        alertPresenter?.showAlert(model: model)
    }
    
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    // вынести в presenter кроме алерта
    
    private func requestNextQuestionAndUpdateUI() {
        guard let question = questionFactory?.requestNextQuestion() else {
            showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
    }
        // вынести в presenter
    private func showNextQuestionOrResults() {
        onOffButtons(true)
        presenter.switchToNextQuestion()
        
        if presenter.accessToCurrentQuestionIndex < presenter.questionsAmount {
            guard let nextQuestion = questionFactory?.requestNextQuestion() else {
                return
            }
            show(quiz: presenter.convert(model: nextQuestion))
        } else {
            alertPresenter?.showResults(correctAnswers: correctAnswers, questionsAmount: presenter.questionsAmount)
        }
    }

    func restartQuiz() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        requestNextQuestionAndUpdateUI()
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertModel = AlertModel(title: title, message: message, buttonText: "ОК", completion: completion)
        alertPresenter?.showAlert(model: alertModel)
    }
 
    // вынести в presenter кроме алерта
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        onOffButtons(false)
        presenter.noButton(sender)
    }
   
    @IBAction private func yesButton(_ sender: UIButton) {
        onOffButtons(false)
        presenter.yesButton(sender)
    }
}
