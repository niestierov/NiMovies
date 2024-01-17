//
//  UIView+ActivityIndicator.swift
//  NiMovies
//
//  Created by Denys Niestierov on 04.01.2024.
//

import UIKit

extension UIView {
    private var activityIndicatorTag: Int {
        return ObjectIdentifier(self).hashValue
    }

    func showActivityIndicator(
        color: UIColor = .default,
        style: UIActivityIndicatorView.Style = .medium
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if viewWithTag(activityIndicatorTag) == nil {
                let activityIndicator = UIActivityIndicatorView(style: style)
                activityIndicator.tag = activityIndicatorTag
                activityIndicator.center = CGPoint(
                    x: bounds.width / 2,
                    y: bounds.height / 2
                )
                activityIndicator.color = color
                activityIndicator.startAnimating()
                addSubview(activityIndicator)
            }
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let activityIndicator = viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
