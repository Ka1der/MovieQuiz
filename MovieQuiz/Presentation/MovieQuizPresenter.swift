//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 14.08.2024.
//

import UIKit

final class MovieQuizPresenter: UIViewController {
    
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var movieQuizViewController: MovieQuizViewController?
    var accessToCurrentQuestionIndex: Int {
        return currentQuestionIndex
    }
    var checkAnswer: ((Bool) -> Bool)?
    var showAnswerResults: ((Bool) -> Void)?
    
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
        let isCorrect = checkAnswer?(answer) ?? false
        showAnswerResults?(isCorrect)
        
    }
    
   func noButton(_ sender: UIButton) {
       handleAnswer(false)
    }
    
    func yesButton(_ sender: UIButton) {
        handleAnswer(true)
    }
}
