//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Alfa on 07.03.2026.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case totalAnswers
        case totalCorrectAnswers
        case bestGame
    }
    
    private(set) var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private var totalAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }

    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalAnswers > 0 else {
            return 0.0
        }

        return Double(totalCorrectAnswers) / Double(totalAnswers) * 100
    }

    private(set) var bestGame: GameResult {
        get {
            guard let bestGameData = storage.data(forKey: Keys.bestGame.rawValue) else {
                return GameResult.empty
            }
            
            let decoder = JSONDecoder()
            
            guard let bestGame = try? decoder.decode(GameResult.self, from: bestGameData) else {
                return GameResult.empty
            }
            
            return bestGame
        }
        set {
            let encoder = JSONEncoder()
            
            if let bestGameData = try? encoder.encode(newValue) {
                storage.set(bestGameData, forKey: Keys.bestGame.rawValue)
            }
        }
    }

    func store(_ gameResult: GameResult) {
        totalAnswers += gameResult.total
        totalCorrectAnswers += gameResult.correct
        gamesCount += 1
        
        if gameResult.isBetterThen(bestGame) {
            bestGame = gameResult
        }
    }
}
