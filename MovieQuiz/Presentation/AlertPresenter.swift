//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kaider on 18.07.2024.
//

import UIKit

class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    private let statisticService: StatisticServiceProtocol
    
    init(delegate: AlertPresenterDelegate, statisticService: StatisticServiceProtocol) {
        self.delegate = delegate
        self.statisticService = statisticService
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        delegate?.presentAlert(alert: alert)
    }
    
    func showResults(correctAnswers: Int, questionsAmount: Int) {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let totalGamesPlayed = statisticService.gamesCount
        let totalAccuracy = statisticService.totalAccuracy * 100
        let formattedAccuracy = String(format: "%.2f", totalAccuracy)
        let bestGame = statisticService.bestGame
        let recordCorrectAnswers = bestGame.correct
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY HH:mm"
        let recordTimesDate = dateFormatter.string(from: bestGame.date)
        
        let message = """
            Ваш результат \(correctAnswers)/\(questionsAmount)
            Количество сыграных квизов: \(totalGamesPlayed)
            Рекорд: \(recordCorrectAnswers)/\(bestGame.total), (\(recordTimesDate))
            Средняя точность: \(formattedAccuracy)%
            """
        
        let alertModel = AlertModel(title: "Этот раунд окончен!", message: message, buttonText: "Сыграть еще раз") { [weak self] in
            self?.delegate?.restartQuiz()
        }
        showAlert(model: alertModel)
    }
}
