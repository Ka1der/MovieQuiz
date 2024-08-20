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
    var correctAnswers: Int = 0
    var recordCorrectAnswers: Int = 0
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
        let sut = MovieQuizPresenter()
        sut.viewControllerProtocol = viewControllerMock
        sut.questionsAmount = 10
        sut.currentQuestionIndex = 0
        let image = UIImage(systemName: "house")?.pngData() ?? Data()
        let question = QuizQuestion(image: image, text: "testQuestion", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image, "Img")
        XCTAssertEqual(viewModel.question, "testQuestion", "testQuestion is mached?")
        XCTAssertEqual(viewModel.questionNumber, "1 / 10", "Question number and current index corerct?")
    }
}
