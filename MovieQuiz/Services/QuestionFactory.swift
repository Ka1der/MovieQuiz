//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Kaider on 14.07.2024.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    weak var delegate:  QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData () {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
            guard let self = self else {return}
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() -> QuizQuestion? {
        guard !movies.isEmpty else { return nil }
             
             let index = (0..<movies.count).randomElement() ?? 0
             let movie = movies[index]
             var imageData = Data()
             do {
                 imageData = try Data(contentsOf: movie.resizedImageURL)
             } catch {
                 print("Failed to load image")
             }
             
             let rating = Float(movie.rating) ?? 0
             let text = "Рейтинг этого фильма больше чем 7?"
             let correctAnswer = rating > 7
             
             let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
             return question
         }
     }
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let index = (0..<self.movies.count).randomElement() ?? 0
//            guard let movie = self.movies[safe: index] else { return }
//            var imageData = Data()
//            do {
//                imageData = try Data(contentsOf: movie.imageURL)
//            } catch {
//                print("Failed to load image")
//            }
//            let rating = Float(movie.rating) ?? 0
//            let text = "Рейтинг этого фильма больше чем 7?"
//            let correctAnswer = rating > 7
//            
//            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
//            
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.delegate?.didReceiveNextQuestion(question: question)
//            }
//        }
//    }
//}
//    weak var delegate: QuestionFactoryDelegate?
//
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(image: "TheGodfather", text: "Рейтинг этого фильма больше чем 4?", correctAnswer: true),
//        QuizQuestion(image: "TheDarkKnight", text: "Рейтинг этого фильма меньше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "KillBill", text: "Рейтинг этого фильма равен 2?", correctAnswer: true),
//        QuizQuestion(image: "TheAvengers", text: "Рейтинг этого фильма больше чем 3?", correctAnswer: true),
//        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма меньше чем 7?", correctAnswer: true),
//        QuizQuestion(image: "TheGreenKnight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "Old", text: "Рейтинг этого фильма равен 6?", correctAnswer: false),
//        QuizQuestion(image: "TheIceAgeAdventuresofBuckWild", text: "Рейтинг этого фильма больше чем 5?", correctAnswer: false),
//        QuizQuestion(image: "Tesla",text: "Рейтинг этого фильма больше чем 9?",correctAnswer: true),
//        QuizQuestion(image: "Vivarium",text: "Рейтинг этого фильма меньше чем 3?",correctAnswer: false)
//    ]
//
//    func setup(delegate: QuestionFactoryDelegate) {
//        self.delegate = delegate
//    }
//
//    func requestNextQuestion() -> QuizQuestion? {
//        guard let index = (0..<questions.count).randomElement() else {
//            delegate?.didReceiveNextQuestion(question: nil)
//            return nil
//        }
//        let question = questions[safe: index]
//        delegate?.didReceiveNextQuestion(question: question)
//        return question
//    }
//}
