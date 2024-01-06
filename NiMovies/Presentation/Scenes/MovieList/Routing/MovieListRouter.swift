//
//  MovieListRouter.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListRouter {
    func showNiPostDetails(movieId: Int)
}

final class DefaultMovieListRouter: BaseRouter, MovieListRouter {
    
    // MARK: - Properties -
    
    var root: UIViewController
    
    // MARK: - Init -
    
    init(root: UIViewController) {
        self.root = root
    }
    
    func showNiPostDetails(movieId: Int) {
        let movieDetails = DefaultMovieDetailsAssembly().createMovieDetails(movieId: movieId)
        root.navigationController?.pushViewController(movieDetails, animated: true)
    }
}
