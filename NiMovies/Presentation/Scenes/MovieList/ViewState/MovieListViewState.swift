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
        let title: String
        let voteAverage: String
    }
    
    var movies: [Movie] = []
}

extension MovieListViewState {    
    mutating func appendMovieList(
        _ movieList: [MovieResult],
        with genreList: [MovieGenre]
    ) {
        let additionalMovies = movieList.compactMap { movie in
            let image = MovieApiConstant.basePosterUrl + (movie.backdropPath ?? "")
            let releaseDate = movie.releaseDate ?? ""
            let title = movie.title + ", " + releaseDate
            let voteAverage = (movie.voteAverage ?? .zero).stringValue
            let genres = movie.genreIds.compactMap { genreId in
                genreList.first { $0.id == genreId }?.name
            }.prefix(3).joined(separator: ", ")
            
            return MovieListViewState.Movie(
                posterUrl: image,
                genres: genres,
                id: movie.id,
                title: title,
                voteAverage: voteAverage
            )
        }
        movies.append(contentsOf: additionalMovies)
    }
}
