//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Kaider on 17.08.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var currentQuestion: MovieQuiz.QuizQuestion?
    
    var correctAnswers: Int
    
    var recordCorrectAnswers: Int
    
    var currentTime: Date?
    
    var questionFactory: (any MovieQuiz.QuestionFactoryProtocol)?
    
    var alertPresenter: MovieQuiz.AlertPresenter?
    
    func show(quiz: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func showAlert(title: String, message: String) {
        
    }
    
    func onOffButtons(_ on: Bool) {
        
    }
    
   
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
