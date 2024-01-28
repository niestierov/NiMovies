//
//  Binder.swift
//  NiMovies
//
//  Created by Denys Niestierov on 27.01.2024.
//

import Foundation

class Bindable<T> {
    
    // MARK: - Properties -
    
    typealias Listener = (T) -> Void
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    // MARK: - Init -
    
    init(_ value: T) {
        self.value = value
    }
    
    // MARK: - Internal -
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
}
