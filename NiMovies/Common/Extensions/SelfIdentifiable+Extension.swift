//
//  SelfIdentifiable+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import Foundation

protocol SelfIdentifiable: AnyObject { }

extension SelfIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
}
