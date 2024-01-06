//
//  MovieListSortType.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

enum MovieListSortType: String, CaseIterable {
    case popularityDescending = "popularity.desc"
    case popularityAscending = "popularity.asc"
    case voteAverageDescending = "vote_average.desc"
    case voteAverageAscending = "vote_average.asc"
    case releaseDateDescending = "primary_release_date.desc"
    case releaseDateAscending = "primary_release_date.asc"
    
    var title: String {
        switch self {
        case .popularityAscending:
            "Popularity ascending"
        case .popularityDescending:
            "Popularity descending"
        case .voteAverageAscending:
            "Vote ascending"
        case .voteAverageDescending:
            "Vote descending"
        case .releaseDateAscending:
            "Release date ascending"
        case .releaseDateDescending:
            "Release date descending"
        }
    }
}
