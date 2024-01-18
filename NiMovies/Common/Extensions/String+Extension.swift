//
//  String+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 18.01.2024.
//

import Foundation

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func asFormattedString(format: String = "dd MMMM yyyy") -> String? {
        guard let date = self.toDate() else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
