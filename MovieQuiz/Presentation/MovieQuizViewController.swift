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
    private var currentQuestion: QuizQuestion?
    private var currentTime: Date?
    private var recordCorrectAnswers = 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter()
        presenter.checkAnswer = {[weak self] answer in return self?.checkAnswer(answer) ?? false}
        presenter.showAnswerResults = {[weak self] isCorrect in self?.showAnswerResults(isCorrect: isCorrect) }
        
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
    
    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
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
    
    func checkAnswer(_ answer: Bool) -> Bool {
        guard let currentQuestion = currentQuestion else {
            showAlert(title: "Ошибка", message: "Вопрос не найден")
            return false
        }
        let isCorrect = currentQuestion.correctAnswer == answer
        if isCorrect {
            correctAnswers += 1
            checkRecordCorrectAnswers()
        }
        return isCorrect
    }
    
    private func requestNextQuestionAndUpdateUI() {
        guard let question = questionFactory?.requestNextQuestion() else {
            showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
    }
    
    private func showNextQuestionOrResults() {
        enableButtons()
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
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertModel = AlertModel(title: title, message: message, buttonText: "ОК", completion: completion)
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func checkRecordCorrectAnswers() {
        if correctAnswers > recordCorrectAnswers {
            recordCorrectAnswers = correctAnswers
            currentTime = Date()
        }
    }
    
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
    
    func didCheckAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            checkRecordCorrectAnswers()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        disableButtons()
        presenter.noButton(sender)
    }
   
    @IBAction private func yesButton(_ sender: UIButton) {
        disableButtons()
        presenter.yesButton(sender)
    }
}
