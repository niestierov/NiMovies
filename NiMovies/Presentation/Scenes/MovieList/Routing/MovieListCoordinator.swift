//
//  MovieListCoordinator.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListCoordinator {
    func showMovieDetails(with configuration: MovieDetailsConfiguration)
}

final class DefaultMovieListCoordinator: BaseCoordinator, MovieListCoordinator {
    
    // MARK: - Properties -
    
    var root: UIViewController
    
    // MARK: - Init -
    
    init(root: UIViewController) {
        self.root = root
    }
    
    func showMovieDetails(with configuration: MovieDetailsConfiguration) {
        let movieDetails = DefaultMovieDetailsAssembly().createMovieDetails(with: configuration)
        root.navigationController?.pushViewController(movieDetails, animated: true)
    }
}

