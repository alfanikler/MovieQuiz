//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Alfa on 07.03.2026.
//

import Foundation

struct GameResult: Decodable, Encodable {
    let correct: Int
    let total: Int
    let date: Date
    
    static var empty: GameResult {
        GameResult(correct: 0, total: 0, date: Date())
    }
    
    var score: Double {
        guard total > 0 else {
            return 0.0
        }

        return Double(correct) / Double(total)
    }
    
    func isBetterThen(_ another: GameResult) -> Bool {
        score > another.score
    }
}
