//
//  MovieItem+CoreDataProperties.swift
//  NiMovies
//
//  Created by Denys Niestierov on 11.01.2024.
//
//

import Foundation
import CoreData

extension MovieItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieItem> {
        return NSFetchRequest<MovieItem>(entityName: "MovieItem")
    }

    @NSManaged public var backdropPath: String?
    @NSManaged public var movieId: Int64
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String
    @NSManaged public var voteAverage: Double
    @NSManaged public var genreIds: [Int]
    @NSManaged public var popularity: Double
}
