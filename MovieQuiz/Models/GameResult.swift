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
        total > 0 ? Double(correct) / Double(total) : 0.0
    }
    
    func isBetterThen(_ another: GameResult) -> Bool {
        score > another.score
    }
}
