//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Alfa on 03.03.2026.
//

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    let completion: () -> Void
}
