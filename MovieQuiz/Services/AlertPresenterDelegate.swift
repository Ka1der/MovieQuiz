//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Kaider on 18.07.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(alert: UIAlertController)
    func restartQuiz()
}
