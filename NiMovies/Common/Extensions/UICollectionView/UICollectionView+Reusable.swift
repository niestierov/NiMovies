//
//  UICollectionView+Reusable.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import UIKit

extension UICollectionViewCell: SelfIdentifiable { }

extension UICollectionView {
    func register(_ cellType: UICollectionViewCell.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.identifier)
    }

    func dequeue<T: UICollectionViewCell>(cellType: T.Type, at indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as! T
    }
}
