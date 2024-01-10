//
//  Optional+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped == String {
    func setDefaultIfNilOrEmpty(_ defaultString: String = "") -> String {
        guard let self else {
            return defaultString
        }
        return self.isEmpty ? defaultString : self
    }
}
