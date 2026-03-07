//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Alfa on 07.03.2026.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(_ gameResult: GameResult)
}
