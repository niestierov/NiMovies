//
//  StringConvertible+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation

protocol StringConvertible {
    var stringValue: String { get }
}

extension Double: StringConvertible {
    var stringValue: String {
        String(format: "%.1f", self)
    }
}

extension Int: StringConvertible {
    var stringValue: String {
        String(self)
    }
}
