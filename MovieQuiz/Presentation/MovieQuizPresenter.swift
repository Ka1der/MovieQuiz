//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 14.08.2024.
//

import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex: Int = 0
    var accessToCurrentQuestionIndex: Int {
        return currentQuestionIndex
    }
    let questionsAmount: Int = 10
    
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
}
