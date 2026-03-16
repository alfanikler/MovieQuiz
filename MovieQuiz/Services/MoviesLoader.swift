//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Alfa on 13.03.2026.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    // MARK: - URL
    private let mostPopularMoviesURL = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf")!;
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
                case .success(let data):
                    do {
                        let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        handler(.success(movies))
                    } catch {
                        handler(.failure(error))
                    }
                case .failure(let error):
                    handler(.failure(error))
            }
        }
    }
}
