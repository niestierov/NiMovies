//
//  MovieGenreItem+CoreDataProperties.swift
//  NiMovies
//
//  Created by Denys Niestierov on 11.01.2024.
//
//

import Foundation
import CoreData

extension MovieGenreItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieGenreItem> {
        return NSFetchRequest<MovieGenreItem>(entityName: "MovieGenreItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String
}

extension MovieGenreItem : Identifiable { }
