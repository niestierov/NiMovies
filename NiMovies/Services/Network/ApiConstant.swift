//
//  ApiConstant.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation

struct ApiConstant {
    struct MovieListFields {
        static let path = "/discover/movie"
        static let page = "page"
        static let sortType = "sort_by"
    }
    
    struct MovieSearchFields {
        static let path = "/search/movie"
        static let query = "query"
        static let page = "page"
    }
    
    struct MovieDetailsFields {
        static let path = "/search/movie"
        static let query = "query"
        static let page = "page"
    }
    
    struct MovieGenreListFields {
        static let path = "/genre/movie/list"
    }
}
