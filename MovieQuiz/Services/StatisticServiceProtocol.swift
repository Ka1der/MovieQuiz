//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Kaider on 20.07.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct || (correct == another.correct && total < another.total)
    }
}
