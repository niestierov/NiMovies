//
//  MovieDetailsHeaderView.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import UIKit

final class MovieDetailsHeaderView: UIView {
    
    // MARK: - UI Components -

    private lazy var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapImageView)
        )
        imageView.backgroundColor = .clear
        imageView.addGestureRecognizer(tapGesture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Properties -
    
    var imageViewTapGestureHandler: EmptyBlock?

    // MARK: - Init -

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    // MARK: - Internal -
    
    func configure(image: String) {
        movieImageView.setImage(
            with: image,
            placeholder: UIImage(named: AppConstant.moviePosterPlaceholderName)
        )
    }
}

// MARK: - Private -

private extension MovieDetailsHeaderView {
    func setupView() {
        addSubview(movieImageView)
        
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: topAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    func didTapImageView() {
        imageViewTapGestureHandler?()
    }
}
