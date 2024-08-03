//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kaider on 15.07.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadDataFromServer(with error: Error)
}

