//
//  MovieListViewState.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import Foundation

struct MovieListViewState {
    struct Movie {
        let posterUrl: String
        let genres: String
        let id: Int
        let releaseDate: String
        let title: String
        let voteAverage: String
    }
    
    var movies: [Movie] = []
}

extension MovieListViewState {
    static func makeViewState(
        for movieList: MovieListResult,
        with genreList: [MovieGenre]
    ) -> MovieListViewState {
        let moviesViewState = makeMovieList(movieList, with: genreList)
        return MovieListViewState(movies: moviesViewState)
    }
    
    static func makeMovieList(
        _ movieList: MovieListResult,
        with genreList: [MovieGenre]
    ) -> [MovieListViewState.Movie] {
        return movieList.results.compactMap { movie in
            let image = MovieConfiguration.basePosterUrl + (movie.backdropPath ?? "")
            let releaseDate = movie.releaseDate ?? ""
            let title = movie.title
            let voteAverage = (movie.voteAverage ?? .zero).stringValue
            let genres = movie.genreIds.compactMap { genreId in
                genreList.first { $0.id == genreId }?.name
            }.prefix(3).joined(separator: ", ")
            
            return MovieListViewState.Movie(
                posterUrl: image,
                genres: genres,
                id: movie.id,
                releaseDate: releaseDate,
                title: title,
                voteAverage: voteAverage
            )
        }
    }
}
