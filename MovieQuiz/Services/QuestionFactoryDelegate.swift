//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alfa on 03.03.2026.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
