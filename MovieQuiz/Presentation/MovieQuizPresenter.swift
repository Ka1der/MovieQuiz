//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 14.08.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    weak var viewControllerProtocol: MovieQuizViewControllerProtocol?
//    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    weak var alertPresenter: AlertPresenter?
    var questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
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
        guard let currentQuestion = currentQuestion
        else {  viewControllerProtocol?.showAlert(title: "Ошибка", message: "Вопрос не найден")
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
            viewControllerProtocol?.showAlert(title: "Ошибка", message: "Вопрос не найден")
            return false
        }
        let isCorrect = question.correctAnswer == answer
        if isCorrect {
            viewControllerProtocol?.correctAnswers += 1
            checkRecordCorrectAnswers()
        }
        return isCorrect
    }
    
    func didCheckAnswer(isCorrect: Bool) {
        if isCorrect {
            viewControllerProtocol?.correctAnswers += 1
            checkRecordCorrectAnswers()
        }
    }
    
    func checkRecordCorrectAnswers() {
        guard let viewController = viewControllerProtocol else { return }
        if correctAnswers > (viewController.recordCorrectAnswers) {
            viewController.recordCorrectAnswers = correctAnswers
            viewController.currentTime = Date()
        }
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            viewControllerProtocol?.showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
        
      currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewControllerProtocol?.show(quiz: viewModel)
        }
    }
    func showNextQuestionOrResults() {
        viewControllerProtocol?.onOffButtons(true)
        switchToNextQuestion()
        
        if accessToCurrentQuestionIndex < questionsAmount {
            guard let nextQuestion =  viewControllerProtocol?.questionFactory?.requestNextQuestion() else {
                return
            }
            let viewModel = convert(model: nextQuestion)
            viewControllerProtocol?.show(quiz: viewModel)
        } else {
            viewControllerProtocol?.alertPresenter?.showResults(correctAnswers:  viewControllerProtocol?.correctAnswers ?? 0, questionsAmount: questionsAmount)
        }
    }
    
    func requestNextQuestionAndUpdateUI() {
        guard let question =  viewControllerProtocol?.questionFactory?.requestNextQuestion() else {
            viewControllerProtocol?.showAlert(title: "Ошибка!", message: "Не удалось загрузить вопросы")
            return
        }
      currentQuestion = question
        let viewModel = convert(model: question)
        viewControllerProtocol?.show(quiz: viewModel)
    }
    func viewDidLoad() {
        viewControllerProtocol?.configureButtons()
        viewControllerProtocol?.showLoadingIndicator(isLoading: true)
        viewControllerProtocol?.questionFactory?.loadData()
    }
}
