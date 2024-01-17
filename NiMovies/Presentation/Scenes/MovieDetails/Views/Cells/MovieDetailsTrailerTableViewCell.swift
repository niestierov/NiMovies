//
//  MovieDetailsTrailerTableViewCell.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import UIKit

final class MovieDetailsTrailerTableViewCell: UITableViewCell {
    private struct Constant {
        static let defaultVerticalInset: CGFloat = 5
        static let defaultHorizontalInset: CGFloat = 20
        static let trailerButtonImageName = "play"
    }
    
    // MARK: - UI Components -

    private lazy var trailerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var trailerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch latest trailer:"
        label.textColor = .default
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var trailerButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: Constant.trailerButtonImageName),
            for: .normal
        )
        button.tintColor = .default
        button.applyRoundedCorners(radius: 20)
        button.backgroundColor = .systemTeal
        button.clipsToBounds = true
        button.addTarget(
            self,
            action: #selector(didTapTrailerButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties -
    
    var trailerButtonTapHandler: EmptyBlock?
    
    // MARK: - Init -

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
}

// MARK: - Private -

private extension MovieDetailsTrailerTableViewCell {
    func setupView() {
        contentView.backgroundColor = .defaultBackground
        
        contentView.addSubview(trailerStackView)
        
        trailerStackView.addArrangedSubview(trailerTitleLabel)
        trailerStackView.addArrangedSubview(trailerButton)
        
        NSLayoutConstraint.activate([
            trailerStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constant.defaultVerticalInset
            ),
            trailerStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constant.defaultHorizontalInset
            ),
            trailerStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constant.defaultHorizontalInset
            ),
            trailerStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            trailerButton.widthAnchor.constraint(
                equalTo: trailerStackView.widthAnchor,
                multiplier: 1/3
            ),
            trailerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    func didTapTrailerButton() {
        trailerButtonTapHandler?()
    }
}
