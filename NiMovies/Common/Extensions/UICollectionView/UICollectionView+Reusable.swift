//
//  UICollectionView+Reusable.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import UIKit

extension UICollectionReusableView: SelfIdentifiable { }

extension UICollectionView {
    
    // MARK: - UICollectionViewCell -
    
    func register(_ cellType: UICollectionViewCell.Type) {
        register(
            cellType.self,
            forCellWithReuseIdentifier: cellType.identifier
        )
    }

    func dequeue<T: UICollectionViewCell>(
        cellType: T.Type,
        at indexPath: IndexPath
    ) -> T {
        dequeueReusableCell(
            withReuseIdentifier: cellType.identifier,
            for: indexPath
        ) as! T
    }
    
    // MARK: - UICollectionReusableView -
    
    func register(
        _ viewClass: UICollectionReusableView.Type,
        forSupplementaryViewOfKind elementKind: String
    ) {
        register(
            viewClass.self,
            forSupplementaryViewOfKind: elementKind,
            withReuseIdentifier: viewClass.identifier
        )
    }
    
    func dequeue<T: UICollectionReusableView>(
        ofKind elementKind: String,
        viewType: T.Type,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: viewType.identifier,
            for: indexPath
        ) as! T
    }
}
