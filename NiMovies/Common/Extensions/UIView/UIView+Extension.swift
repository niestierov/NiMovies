//
//  UIView+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 28.12.2023.
//

import UIKit

extension UIView {
    func applyShadow(
        color: CGColor = UIColor.black.cgColor,
        opacity: Float = 1,
        offset: CGSize = CGSize.zero,
        radius: CGFloat = 1
    ) {
        self.layer.shadowColor = color
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func applyRoundedCorners(
        radius: CGFloat = 10,
        curve: CALayerCornerCurve = .continuous
    ) {
        self.layer.cornerRadius = radius
        self.layer.cornerCurve = curve
    }
    
    func applyPriority(
        contentHuggingPriority: UILayoutPriority = .required,
        contentHuggingAxis: NSLayoutConstraint.Axis = .horizontal,
        contentCompressionResistancePriority : UILayoutPriority = .required,
        contentCompressionResistanceAxis: NSLayoutConstraint.Axis = .horizontal
    ) {
        self.setContentHuggingPriority(
            contentHuggingPriority,
            for: contentHuggingAxis
        )
        self.setContentCompressionResistancePriority(
            contentCompressionResistancePriority,
            for: contentCompressionResistanceAxis
        )
    }
}
