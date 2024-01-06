//
//  UIAlertAction+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 05.01.2024.
//

import UIKit

extension UIAlertAction {
    static func cancelAction(
        title: String = "Cancel",
        handler: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertAction {
        return UIAlertAction(
            title: title,
            style: .cancel,
            handler: handler
        )
    }
    
    var isChecked: Bool {
        get {
            return value(forKey: UIAlertAction.isCheckedKey) as? Bool ?? false
        }
        set {
            setValue(newValue, forKey: UIAlertAction.isCheckedKey)
        }
    }
    
    private static var isCheckedKey: String = "checked"
}
