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
    static func makeMovie(_ movie: MovieDetailsResult) -> MovieDetailsViewState.Movie {
        let backdropUrlString = MovieConfiguration.basePosterUrl + (movie.backdropPath ?? "")
        let posterUrlString = MovieConfiguration.basePosterUrl + (movie.posterPath ?? "")
        let voteAverage = (movie.voteAverage ?? .zero).stringValue
        let title = setDefaultValueIfNeeded(
            for: movie.title,
            with: "Title unknown."
        )
        let unpackedGenres = movie.genres?.compactMap { $0.name }.joined(separator: ", ")
        let genres = setDefaultValueIfNeeded(
            for: unpackedGenres,
            with: "Genres unknown."
        )
        let releaseDate = setDefaultValueIfNeeded(
            for: movie.releaseDate,
            with: "Release unknown."
        )
        let country = setDefaultValueIfNeeded(
            for: movie.productionCountries?.first?.name,
            with: "Production unknown."
        )
        let overview = setDefaultValueIfNeeded(
            for: movie.overview,
            with: "It looks like there is no description."
        )
        
        return MovieDetailsViewState.Movie(
            title: title,
            backdropUrlString: backdropUrlString, 
            posterUrlString: posterUrlString,
            genres: genres,
            overview: overview, 
            voteAverage: voteAverage, 
            country: country,
            releaseDate: releaseDate
        )
        
//        let backdropUrlString = MovieConfiguration.basePosterUrl + (movie.backdropPath ?? "")
//        let posterUrlString = MovieConfiguration.basePosterUrl + (movie.posterPath ?? "")
//        let voteAverage = (movie.voteAverage ?? .zero).stringValue
//        let title
//        let genres
//        let country
//        let overview
    }
    
    private static func setDefaultValueIfNeeded<T>(for value: T?, with defaultValue: String) -> String {
        guard let value else {
            return defaultValue
        }
        let stringValue = String(describing: value)
        
        return stringValue.isEmpty ? defaultValue : stringValue
    }
}
