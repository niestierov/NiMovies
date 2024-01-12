//
//  AppConstant.swift
//  NiMovies
//
//  Created by Denys Niestierov on 05.01.2024.
//

import Foundation

typealias EmptyBlock = () -> Void
typealias EndpointRequestCompletion<T: Codable> = (Result<Endpoint<T>.ResponseType?, Error>) -> Void

struct AppConstant {
    static let initialLoadingAnimationName = "InitialLoadingAnimation"
    static let moviePosterPlaceholderName = "MoviePosterPlaceholder"
    static let defaultErrorMessage = "Something went wrong..."
    static let noInternetConnectionErrorMessage = "You are offline. Please, enable your WiFi or connect using cellular data."
    static let noResultsImagePlaceholderName = "NoResultsImagePlaceholder"
}
