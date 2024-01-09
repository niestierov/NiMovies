//
//  MovieListFooterView.swift
//  NiMovies
//
//  Created by Denys Niestierov on 09.01.2024.
//

import UIKit

final class MovieListFooterView: UICollectionReusableView {

    // MARK: - Init -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: - Private -
    
    private func setupView() {
        backgroundColor = .clear
        showActivityIndicator()
    }
}
