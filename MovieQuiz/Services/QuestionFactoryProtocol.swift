//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Kaider on 15.07.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func setup(delegate: QuestionFactoryDelegate)
    func requestNextQuestion() -> QuizQuestion?
}
