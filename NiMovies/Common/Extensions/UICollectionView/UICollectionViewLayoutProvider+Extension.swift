//
//  UICollectionViewLayoutProvider+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import UIKit

protocol UICollectionViewLayoutProvider {
    func createItem(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) -> NSCollectionLayoutItem

    func createVerticalGroup(
        with subitems: [NSCollectionLayoutItem],
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) -> NSCollectionLayoutGroup

    func createHorizontalGroup(
        with subitems: [NSCollectionLayoutItem],
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) -> NSCollectionLayoutGroup

    func createSection(with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection
    func createFooter(
        ofKind: String,
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        alignment: NSRectAlignment
    ) -> NSCollectionLayoutBoundarySupplementaryItem
}

extension UICollectionViewLayoutProvider {
    func createItem(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44)
    ) -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }

    func createVerticalGroup(
        with subitems: [NSCollectionLayoutItem],
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44)
    ) -> NSCollectionLayoutGroup {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        return NSCollectionLayoutGroup.vertical(
            layoutSize: layoutSize,
            subitems: subitems
        )
    }

    func createHorizontalGroup(
        with subitems: [NSCollectionLayoutItem],
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44)
    ) -> NSCollectionLayoutGroup {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        return NSCollectionLayoutGroup.horizontal(
            layoutSize: layoutSize,
            subitems: subitems
        )
    }

    func createSection(with group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        NSCollectionLayoutSection(group: group)
    }
    
    func createFooter(
        ofKind: String,
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = .bottom
    ) -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: ofKind,
            alignment: alignment
        )
        return footer
    }
}

