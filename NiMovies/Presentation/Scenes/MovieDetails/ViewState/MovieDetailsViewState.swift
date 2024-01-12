//
//  MovieDetailsViewState.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Foundation

struct MovieDetailsViewState {
    enum Section {
        case trailerItem(TrailerItem)
        case attributeItem(AttributeItem)
    }
    
    struct TrailerItem {
        let cell: Cell
        
        struct Cell {
            let isTrailerAvailable: Bool
        }
    }

    struct AttributeItem {
        let header: Header
        let cell: Cell
        
        struct Cell {
            let description: String
        }
        
        enum Header: String {
            case title = "Title"
            case genres = "Genres"
            case releaseDate = "Release date"
            case description = "Description"
            case rating = "Rating"
            case production = "Production"
        }
    }
    
    struct MovieDetailsHeader {
        let backdrop: String
        let poster: String?
    }
    
    let title: String
    let header: MovieDetailsHeader?
    let sections: [Section]
}

extension MovieDetailsViewState {
    static func makeInitialViewState(
        with configuration: MovieDetailsConfiguration
    ) -> MovieDetailsViewState {
        return MovieDetailsViewState(
            title: configuration.title,
            header: nil,
            sections: []
        )
    }
    
    static func makeViewState(
        movieDetails: MovieDetailsResult,
        videoKeys: [String]?
    ) -> MovieDetailsViewState {
        let genres = movieDetails.genres?.compactMap { $0.name }.joined(separator: ", ")
        
        let titleSectionDescription = movieDetails.title.setDefaultIfNilOrEmpty("Title unknown")
        let genresSectionDescription = genres.setDefaultIfNilOrEmpty("Genres unknown")
        let releaseSectionDescription = movieDetails.releaseDate.setDefaultIfNilOrEmpty("Release unknown")
        let descriptionSectionDescription = movieDetails.title.setDefaultIfNilOrEmpty("Genres unknown")
        let ratingSectionDescription = (movieDetails.voteAverage ?? .zero).stringValue
        let productionSectionDescription = movieDetails.title.setDefaultIfNilOrEmpty("Genres unknown")
        let trailerSectionAvailable = !videoKeys.isEmptyOrNil
        
        let sections: [MovieDetailsViewState.Section] = [
            makeAttributeSection(
                header: .title,
                description: titleSectionDescription
            ),
            makeAttributeSection(
                header: .genres,
                description: genresSectionDescription
            ),
            makeAttributeSection(
                header: .releaseDate,
                description: releaseSectionDescription
            ),
            makeAttributeSection(
                header: .description,
                description: descriptionSectionDescription
            ),
            makeAttributeSection(
                header: .rating,
                description: ratingSectionDescription
            ),
            makeAttributeSection(
                header: .production,
                description: productionSectionDescription
            ),
            makeTrailerSection(isTrailerAvailable: trailerSectionAvailable)
        ]
        
        let backdropUrlString = MovieApiConstant.basePosterUrl + movieDetails.backdropPath.setDefaultIfNilOrEmpty()
        
        var posterUrlString: String?
        if let posterPath = movieDetails.posterPath {
            posterUrlString = MovieApiConstant.basePosterUrl + posterPath
        }
        
        let header = MovieDetailsHeader(
            backdrop: backdropUrlString,
            poster: posterUrlString
        )
        let title = movieDetails.title.setDefaultIfNilOrEmpty("Title")
        
        return MovieDetailsViewState(
            title: title, 
            header: header,
            sections: sections
        )
    }
}

// MARK: - Private -

private extension MovieDetailsViewState {
    static func makeAttributeSection(
        header: AttributeItem.Header,
        description: String
    ) -> MovieDetailsViewState.Section {
        let cell = AttributeItem.Cell(description: description)
        let attributeItem = AttributeItem(
            header: header,
            cell: cell
        )
        return MovieDetailsViewState.Section.attributeItem(attributeItem)
    }
    
    static func makeTrailerSection(isTrailerAvailable: Bool) -> MovieDetailsViewState.Section {
        let cell = TrailerItem.Cell(isTrailerAvailable: isTrailerAvailable)
        let trailerItem = TrailerItem(cell: cell)
        return MovieDetailsViewState.Section.trailerItem(trailerItem)
    }
}



