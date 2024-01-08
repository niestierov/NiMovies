//
//  MovieListSortType.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

enum MovieListSortType: String, CaseIterable {
    case popularityDescending = "popularity.desc"
    case voteAverageDescending = "vote_average.desc"
    case releaseDateDescending = "primary_release_date.desc"
    
    var title: String {
        switch self {
        case .popularityDescending:
            "Popularity descending"
        case .voteAverageDescending:
            "Vote descending"
        case .releaseDateDescending:
            "Release date descending"
        }
    }
}
