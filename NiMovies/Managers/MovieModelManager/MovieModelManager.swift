//
//  MovieModelManager.swift
//  NiMovies
//
//  Created by Denys Niestierov on 11.01.2024.
//

import UIKit

protocol MovieModelManager {
    func performModelUpdate<T>(
        with array: [T],
        errorHandler: @escaping (Error) -> Void
    )
    func performMovieListUpdate(
        _ movieList: inout [MovieResult],
        group: DispatchGroup?,
        errorHandler: @escaping (Error) -> Void
    )
    func performMovieGenresUpdate(
        _ genreList: inout [MovieGenre],
        group: DispatchGroup?,
        errorHandler: @escaping (Error) -> Void
    )
    func removeMovieItems(
        errorHandler: @escaping (Error) -> Void
    )
}

final class DefaultMovieModelManager: MovieModelManager {
    
    // MARK: - Properties -
    
    static let shared: MovieModelManager = DefaultMovieModelManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    // MARK: - Init -
    
    private init() { }
    
    // MARK: - Internal -
    
    func removeMovieItems(errorHandler: @escaping (Error) -> Void) {
        let fetchRequest = MovieItem.fetchRequest()

        do {
            let objects = try context.fetch(fetchRequest)
            for case let object in objects {
                context.delete(object)
            }
            try context.save()
        } catch {
            errorHandler(error)
        }
    }
    
    func performModelUpdate<T>(
        with array: [T],
        errorHandler: @escaping (Error) -> Void
    ) {
        switch T.self {
        case is MovieResult.Type:
            performMovieListModelUpdate(
                with: array as! [MovieResult],
                errorHandler: errorHandler
            )
        case is MovieGenre.Type:
            performMovieGenresModelUpdate(
                with: array as! [MovieGenre],
                errorHandler: errorHandler
            )
        default:
            break
        }
    }
    
    func performMovieListUpdate(
        _ movieList: inout [MovieResult],
        group: DispatchGroup? = nil,
        errorHandler: @escaping (Error) -> Void
    ) {
        group?.enter()
        let movieModels = getMovieListModels() ?? []
        
        let newMovieList = movieModels.compactMap { movie in
            return MovieResult(
                backdropPath: movie.backdropPath,
                genreIds: movie.genreIds,
                id: Int(movie.movieId),
                releaseDate: movie.releaseDate,
                title: movie.title,
                voteAverage: movie.voteAverage,
                popularity: movie.popularity
            )
        }
        
        movieList = newMovieList
        group?.leave()
    }
    
    func performMovieGenresUpdate(
        _ genreList: inout [MovieGenre],
        group: DispatchGroup? = nil,
        errorHandler: @escaping (Error) -> Void
    ) {
        group?.enter()
        let genreListModel = getMovieGenreModels() ?? []
        
        genreList = genreListModel.compactMap { genre in
            return MovieGenre(
                id: Int(genre.id),
                name: genre.name
            )
        }
        group?.leave()
    }
}

// MARK: - Private -

private extension DefaultMovieModelManager {
    func saveContext(errorHandler: @escaping (Error) -> Void) {
        do {
            try context.save()
        } catch let error {
            errorHandler(error)
        }
    }
    
    func performMovieGenresModelUpdate(
        with genres: [MovieGenre],
        errorHandler: @escaping (Error) -> Void
    ) {
        genres.forEach { genre in
            let item = MovieGenreItem(context: context)
            item.id = Int64(genre.id)
            item.name = genre.name
        }
        saveContext(errorHandler: errorHandler)
    }
    
    func performMovieListModelUpdate(
        with movies: [MovieResult],
        errorHandler: @escaping (Error) -> Void
    ) {
        movies.forEach { movie in
            let item = MovieItem(context: context)
            item.movieId = Int64(movie.id)
            item.title = movie.title
            item.genreIds = movie.genreIds
            item.backdropPath = movie.backdropPath
            item.voteAverage = movie.voteAverage ?? .zero
            item.releaseDate = movie.releaseDate
            item.popularity = movie.popularity ?? .zero
        }
        saveContext(errorHandler: errorHandler)
    }
    
    func getMovieListModels() -> [MovieItem]? {
        do {
            let fetchRequest = MovieItem.fetchRequest()
            let sortDescriptor = NSSortDescriptor(
                key: "popularity",
                ascending: false
            )
            fetchRequest.sortDescriptors = [sortDescriptor]
            return try context.fetch(fetchRequest)
            
        } catch {
            return nil
        }
    }
    
    func getMovieGenreModels() -> [MovieGenreItem]? {
        do {
            return try context.fetch(MovieGenreItem.fetchRequest())
        } catch {
            return nil
        }
    }
}
