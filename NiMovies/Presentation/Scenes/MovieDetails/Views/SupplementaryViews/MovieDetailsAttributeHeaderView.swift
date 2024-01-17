//
//  MovieDetailsAttributeHeaderView.swift
//  NiMovies
//
//  Created by Denys Niestierov on 10.01.2024.
//

import UIKit

final class MovieDetailsAttributeHeaderView: UITableViewHeaderFooterView {
    private struct Constant {
        static let defaultHorizontalInset: CGFloat = 20
    }
    
    // MARK: - UI Components -

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .default
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init -

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    // MARK: - Internal -
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Private -

private extension MovieDetailsAttributeHeaderView {
    func setupView() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 10
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constant.defaultHorizontalInset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constant.defaultHorizontalInset
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -5
            ),
        ])
    }
}
