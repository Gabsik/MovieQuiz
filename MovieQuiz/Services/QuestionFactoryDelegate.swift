//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by User on 06.01.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
