//
//  MovieDetailsViewState.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

struct MovieDetailsViewState {
    struct Movie {
        let title: String
        let backdropUrlString: String
        let posterUrlString: String
        let genres: String
        let overview: String
        let voteAverage: String
        let country: String
        let releaseDate: String
    }
    
    var movie: Movie?
}

extension MovieDetailsViewState {
    static func makeViewState(for movie: MovieDetailsResult) -> MovieDetailsViewState {
        let moviesViewState = makeMovie(movie)
        return MovieDetailsViewState(movie: moviesViewState)
    }
    
    static func makeMovie(_ movie: MovieDetailsResult) -> MovieDetailsViewState.Movie {
        let genres = movie.genres.map { genre in
            return genre.name
        }.joined(separator: ", ")
        let releaseDate = movie.releaseDate ?? "Release unknown"
        let country = movie.productionCountries.first?.name ?? "Production unknown"
        let voteAverage = movie.voteAverage.stringValue
        let overview = movie.overview ?? "It Looks like there is no description."
        let backdropUrlString = MovieConfiguration.basePosterUrl + (movie.backdropPath ?? "")
        let posterUrlString = MovieConfiguration.basePosterUrl + (movie.posterPath ?? "")
        
        return MovieDetailsViewState.Movie(
            title: movie.title,
            backdropUrlString: backdropUrlString, 
            posterUrlString: posterUrlString,
            genres: genres,
            overview: overview, 
            voteAverage: voteAverage, 
            country: country,
            releaseDate: releaseDate
        )
    }
}
