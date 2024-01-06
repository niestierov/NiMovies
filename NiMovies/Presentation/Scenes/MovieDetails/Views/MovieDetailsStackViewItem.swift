//
//  MovieDetailsStackViewItem.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import UIKit

final class MovieDetailsStackViewItem: UIStackView {

    // MARK: - UI Components -
    
    lazy var prefixLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init -

    init(title: String? = nil) {
        super.init(frame: .zero)
        
        prefixLabel.text = title
        setupStackView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupStackView()
    }
    
    // MARK: - Internal -
    
    var contentText: String? {
        didSet {
            contentLabel.text = contentText
        }
    }
}

// MARK: - Private -

private extension MovieDetailsStackViewItem {
    func setupStackView() {
        axis = .vertical
        spacing = 10
        addArrangedSubview(prefixLabel)
        addArrangedSubview(contentLabel)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
