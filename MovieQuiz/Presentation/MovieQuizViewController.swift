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
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var currentTime: Date?
    private var recordCorrectAnswers = 0
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        self.alertPresenter = AlertPresenter(delegate: self, statisticService: statisticService)
        
        requestNextQuestionAndUpdateUI()
        configureButtons()
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadincIndcicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(model: model)
    }
    
    private func configureButtons() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
    }
    
    private func checkAnswer(_ answer: Bool) -> Bool {
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
        guard let firstQuestion = questionFactory?.requestNextQuestion() else {
            showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
        currentQuestion = firstQuestion
        let viewModel = convert(model: firstQuestion)
        show(quiz: viewModel)
    }
    
    private func showNextQuestionOrResults() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        currentQuestionIndex += 1
        
        if currentQuestionIndex < questionsAmount {
            guard let nextQuestion = questionFactory?.requestNextQuestion() else {
                return
            }
            show(quiz: convert(model: nextQuestion))
        } else {
            alertPresenter?.showResults(correctAnswers: correctAnswers, questionsAmount: questionsAmount)
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        requestNextQuestionAndUpdateUI()
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
        let viewModel = convert(model: question)
        
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
    }
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionStep = QuizStepViewModel(
//            image: UIImage(named: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
//        )
//        return questionStep
//    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButton(_ sender: UIButton) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        let isCorrect = checkAnswer(false)
        showAnswerResults(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let isCorrect = checkAnswer(true)
        showAnswerResults(isCorrect: isCorrect)
    }
    
}
