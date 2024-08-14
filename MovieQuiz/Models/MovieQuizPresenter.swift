//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 14.08.2024.
//

import Foundation

final class MovieQuizPresenter {
    var currentQuestionIndex: Int = 0
    var questionsAmount: Int = 10
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel (
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
        }
}
