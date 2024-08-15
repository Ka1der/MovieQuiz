//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 14.08.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var checkAnswer: ((Bool) -> Bool)?
    var showAnswerResults: ((Bool) -> Void)?
    var correctAnswers = 0
    var accessToCurrentQuestionIndex: Int {
        return currentQuestionIndex
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func handleAnswer(_ answer: Bool) {
        guard let currentQuestion = viewController?.currentQuestion else {
            viewController?.showAlert(title: "Ошибка", message: "Вопрос не найден")
            return
        }
        
        let isCorrect = checkAnswer(answer, currentQuestion: currentQuestion)
        showAnswerResults?(isCorrect)
    }
    
    func noButton(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    func yesButton(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    private func checkAnswer(_ answer: Bool, currentQuestion: QuizQuestion?) -> Bool {
        guard let question = currentQuestion else {
            viewController?.showAlert(title: "Ошибка", message: "Вопрос не найден")
            return false
        }
        let isCorrect = question.correctAnswer == answer
        if isCorrect {
            viewController?.correctAnswers += 1
           checkRecordCorrectAnswers()
        }
        return isCorrect
    }
    
    func didCheckAnswer(isCorrect: Bool) {
        if isCorrect {
            viewController?.correctAnswers += 1
            checkRecordCorrectAnswers()
        }
    }
    
    func checkRecordCorrectAnswers() {
        guard let viewController = viewController else { return }
        if correctAnswers > (viewController.recordCorrectAnswers) {
            viewController.recordCorrectAnswers = correctAnswers
            viewController.currentTime = Date()
        }
    }
}
