//
//  MovieListCollectionViewCell.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import UIKit

final class MovieListCollectionViewCell: UICollectionViewCell {
    private struct Constant {
        static let defaultInset: CGFloat = 15
        static let cornerRadius: CGFloat = 10
        static let defaultTextSize: CGFloat = 18
        static let gradientLayerColors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
    }
    
    // MARK: - UI Components -
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constant.cornerRadius
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: Constant.defaultTextSize, weight: .medium)
        label.textColor = .white
        label.applyShadow(color: UIColor.black.cgColor, radius: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 15
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constant.defaultTextSize, weight: .light)
        label.textColor = .white
        label.applyShadow(color: UIColor.black.cgColor, radius: 0.6)
        label.applyPriority(
            contentHuggingPriority: .defaultLow, 
            contentCompressionResistancePriority: .defaultLow
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constant.defaultTextSize, weight: .light)
        label.textColor = .white
        label.applyShadow(color: UIColor.black.cgColor, radius: 0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = posterImageView.bounds
        gradientLayer.colors = Constant.gradientLayerColors
        gradientLayer.locations = [0, 0.3, 0.7, 1]
        return gradientLayer
    }()
    
    // MARK: - Life Cycle -

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupCell()
    }
    
    // MARK: - Internal -
    
    func configure(with movie: MovieListViewState.Movie) {
        posterImageView.prepareForReload()
        
        posterImageView.setImage(
            with: movie.posterUrl,
            placeholder: UIImage(named: AppConstant.moviePosterPlaceholderName)
        )
        titleLabel.text = movie.title
        genresLabel.text = movie.genres
        ratingLabel.text = movie.voteAverage
    }
}

// MARK: - Private -

private extension MovieListCollectionViewCell {
    func setupCell() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(genresLabel)
        stackView.addArrangedSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constant.defaultInset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constant.defaultInset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constant.defaultInset
            ),
            
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constant.defaultInset
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constant.defaultInset
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constant.defaultInset
            ),
        ])
        
        contentView.applyRoundedCorners(radius: Constant.cornerRadius)
        contentView.applyShadow(
            color: UIColor.black.cgColor,
            opacity: 0.5,
            offset: CGSize(width: .zero, height: 2),
            radius: 4
        )
        contentView.layoutIfNeeded()
        
        posterImageView.layer.addSublayer(gradientLayer)
    }
}

