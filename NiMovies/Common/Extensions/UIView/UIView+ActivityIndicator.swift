//
//  UIView+ActivityIndicator.swift
//  NiMovies
//
//  Created by Denys Niestierov on 04.01.2024.
//

import UIKit

extension UIView {
    private var activityIndicatorTag: Int {
        return 999
    }

    func showActivityIndicator(style: UIActivityIndicatorView.Style = .medium) {
        if viewWithTag(activityIndicatorTag) == nil {
            let activityIndicator = UIActivityIndicatorView(style: style)
            activityIndicator.tag = activityIndicatorTag
            activityIndicator.center = center
            activityIndicator.startAnimating()
            addSubview(activityIndicator)
        }
    }

    func hideActivityIndicator() {
        if let activityIndicator = viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}
