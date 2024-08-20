//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Kaider on 17.08.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    var currentQuestion: QuizQuestion? { get set }
    var correctAnswers: Int { get set }
    var recordCorrectAnswers: Int { get set }
    var currentTime: Date? { get set }
    var questionFactory: QuestionFactoryProtocol? { get }
    var alertPresenter: AlertPresenter? { get }
    
    func show(quiz: QuizStepViewModel)
    func showAlert(title: String, message: String)
    func didTapOfButtons(_ on: Bool)
    func configureButtons()
    func showLoadingIndicator(isLoading: Bool)
}
