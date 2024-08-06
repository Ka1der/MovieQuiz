//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Kaider on 20.07.2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case totalAccuracy
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
        
    }
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: Keys.correct.rawValue)
        let totalQuestionsAnswered = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestionsAnswered > 0 else {
            return 0.0
        }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAnswered))
    }
    
    
    func store(correct count: Int, total amount: Int) {
        let totalCorrectAnswers = storage.integer(forKey: Keys.correct.rawValue) + count
        let totalQuestionsAnswered = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        
        storage.set(totalCorrectAnswers, forKey: Keys.correct.rawValue)
        storage.set(totalQuestionsAnswered, forKey: Keys.totalQuestions.rawValue)
        
        gamesCount += 1
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(bestGame) {
            bestGame = currentGameResult
        }
    }
}
