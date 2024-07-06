import UIKit

final class MovieQuizViewController: UIViewController {
//Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    //Variables
    private var currentTime: Date?
    private var recordTimesDate: String = ""
    private var recordCorrectAnswers = 0
    private var totalGamesPlayed = 0
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "TheGodfather", text: "Рейтинг этого фильма больше чем 4?", correctAnswer: true),
        QuizQuestion(image: "TheDarkKnight", text: "Рейтинг этого фильма меньше чем 6?", correctAnswer: true),
        QuizQuestion(image: "KillBill", text: "Рейтинг этого фильма равен 2?", correctAnswer: true),
        QuizQuestion(image: "TheAvengers", text: "Рейтинг этого фильма больше чем 3?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма меньше чем 7?", correctAnswer: true),
        QuizQuestion(image: "TheGreenKnight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма равен 6?", correctAnswer: false),
        QuizQuestion(image: "TheIceAgeAdventuresofBuckWild", text: "Рейтинг этого фильма больше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Tesla",text: "Рейтинг этого фильма больше чем 9?",correctAnswer: false),
        QuizQuestion(image: "Vivarium",text: "Рейтинг этого фильма меньше чем 3?",correctAnswer: false)
    ]
//Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[currentQuestionIndex]))
        configureButtons()
    }
//Actions
    @IBAction private func noButton(_ sender: UIButton) {
        let isCorrect = checkAnswer(false)
            showAnswerResults(isCorrect: isCorrect)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
        }
    @IBAction private func yesButton(_ sender: UIButton) {
        sender.layer.cornerRadius = 15
        let isCorrect = checkAnswer(true)
           showAnswerResults(isCorrect: isCorrect)
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               self.showNextQuestionOrResults()
           }
       }
//Funcs
    private func configureButtons() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    private func checkAnswer(_ answer: Bool) -> Bool {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = currentQuestion.correctAnswer == answer
        if isCorrect {
            correctAnswers += 1
            checkRecordCorrectAnswers()
        }
        return isCorrect
    }
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.red.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.imageView.layer.borderColor = UIColor.ypWhite.cgColor
            }
        }
    private func checkRecordCorrectAnswers() {
        if correctAnswers > recordCorrectAnswers {
            recordCorrectAnswers = correctAnswers
            currentTime = Date()
        }
    }
    // Функция показа следующего вопроса или результатов
    private func showNextQuestionOrResults() {
        currentQuestionIndex += 1
        if let recordTime = currentTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YY HH:mm"
            let recordTimeString = dateFormatter.string(from: recordTime)
            recordTimesDate = recordTimeString
        }
        if currentQuestionIndex < questions.count {
            let nextQuestion = questions[currentQuestionIndex]
            show(quiz: convert(model: nextQuestion))
        } else {
            totalGamesPlayed += 1
            let accuracy = (Double(correctAnswers) / Double(questions.count) * 100)
            let formattetAccuracy = String(format: "%.2f", accuracy)
            let alert = UIAlertController(
                title: "Раунд окончен!",
                message: "Ваш результат \(correctAnswers) из \(questions.count) \n Средняя точность: \(formattetAccuracy)% \n Количество сыгранных игр: \(totalGamesPlayed) \n Рекорд: \(recordCorrectAnswers) (\(recordTimesDate))",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Попробовать еще раз", style: .default, handler: { _ in
                self.restartQuiz()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    private func restartQuiz() {
            currentQuestionIndex = 0
            correctAnswers = 0
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
   }
struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}



