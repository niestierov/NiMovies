//
//  UITableView+Reusable.swift
//  NiMovies
//
//  Created by Denys Niestierov on 09.01.2024.
//

import UIKit

extension UITableViewCell: SelfIdentifiable { }
extension UITableViewHeaderFooterView: SelfIdentifiable { }

extension UITableView {
    
    // MARK: - UITableViewCell -
    
    func register(_ cellType: UITableViewCell.Type) {
        register(
            cellType.self,
            forCellReuseIdentifier: cellType.identifier
        )
    }
    
    func dequeue<T: UITableViewCell>(
        _ cellType: T.Type,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableCell(
            withIdentifier: cellType.identifier,
            for: indexPath
        ) as! T
    }
    
    // MARK: - UITableViewHeaderFooterView -
    
    func register(_ cellType: UITableViewHeaderFooterView.Type) {
        register(
            cellType.self,
            forHeaderFooterViewReuseIdentifier: cellType.identifier
        )
    }
    
    func dequeue<T: UITableViewHeaderFooterView>(_ cellType: T.Type) -> T {
        dequeueReusableHeaderFooterView(withIdentifier: cellType.identifier) as! T
    }
}
