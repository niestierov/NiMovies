//
//  MovieDetailsHeaderView.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import UIKit

final class MovieDetailsHeaderView: UIView {
    
    // MARK: - Properties -
    
    private var imageViewHeight: NSLayoutConstraint!
    private var imageViewBottom: NSLayoutConstraint!
    private var contentViewHeight: NSLayoutConstraint!
    
    // MARK: - UI Components -

    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapImageView)
        )
        imageView.clipsToBounds = true
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
    
    func updateOnViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        contentViewHeight.constant = scrollView.contentInset.top
        contentView.clipsToBounds = offsetY <= .zero

        imageViewBottom.constant = offsetY >= .zero ? .zero : -offsetY / 2
        imageViewHeight.constant = max(
            offsetY + scrollView.contentInset.top,
            scrollView.contentInset.top
        )
    }
}

// MARK: - Private -

private extension MovieDetailsHeaderView {
    func setupView() {
        addSubview(contentView)
        contentView.addSubview(movieImageView)
        
        contentViewHeight = contentView.heightAnchor
            .constraint(equalTo: heightAnchor)
        imageViewBottom = movieImageView.bottomAnchor
            .constraint(equalTo: contentView.bottomAnchor)
        imageViewHeight = movieImageView.heightAnchor
            .constraint(equalTo: contentView.heightAnchor)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            widthAnchor.constraint(equalTo: contentView.widthAnchor),
            heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
            contentView.widthAnchor.constraint(equalTo: movieImageView.widthAnchor),
            
            contentViewHeight,
            imageViewBottom,
            imageViewHeight,
        ])
    }
    
    @objc
    func didTapImageView() {
        imageViewTapGestureHandler?()
    }
}
