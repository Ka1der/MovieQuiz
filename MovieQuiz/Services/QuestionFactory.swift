//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Kaider on 14.07.2024.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "TheGodfather", text: "Рейтинг этого фильма больше чем 4?", correctAnswer: true),
        QuizQuestion(image: "TheDarkKnight", text: "Рейтинг этого фильма меньше чем 6?", correctAnswer: true),
        QuizQuestion(image: "KillBill", text: "Рейтинг этого фильма равен 2?", correctAnswer: true),
        QuizQuestion(image: "TheAvengers", text: "Рейтинг этого фильма больше чем 3?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма меньше чем 7?", correctAnswer: true),
        QuizQuestion(image: "TheGreenKnight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма равен 6?", correctAnswer: false),
        QuizQuestion(image: "TheIceAgeAdventuresofBuckWild", text: "Рейтинг этого фильма больше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Tesla",text: "Рейтинг этого фильма больше чем 9?",correctAnswer: true),
        QuizQuestion(image: "Vivarium",text: "Рейтинг этого фильма меньше чем 3?",correctAnswer: false)
    ]
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return nil
        }
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
        return question
    }
}
