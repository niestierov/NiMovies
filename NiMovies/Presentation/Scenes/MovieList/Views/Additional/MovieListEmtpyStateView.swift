//
//  MovieListEmtpyStateView.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import UIKit

final class MovieListEmtpyStateView: UIView {
    
    // MARK: - UI Components -
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.backgroundColor = .blue
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.tintColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing found."
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
}

// MARK: - Private -

private extension MovieListEmtpyStateView {
    func setupView() {
        backgroundColor = .red
        
        addSubview(titleLabel)
        
        //stackView.addArrangedSubview(imageView)
        //stackView.addArrangedSubview(titleLabel)
        print(self.bounds.width)
        layoutIfNeeded()
        print(self.bounds.width)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            //imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/6),
            //imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
}
