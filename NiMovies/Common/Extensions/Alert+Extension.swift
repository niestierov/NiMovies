//
//  Alert+Extension.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import UIKit

protocol Alert: UIViewController {
    func showAlert(
        title: String,
        message: String?,
        actions: [AlertButtonAction]?
    )
}

extension Alert {
    func showAlert(
        title: String = "Error",
        message: String?,
        actions: [AlertButtonAction]? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertActions = actions ?? [AlertButtonAction.default()]
        
        alertActions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.completion?()
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

struct AlertButtonAction {
    let title: String
    let style: UIAlertAction.Style
    let completion: EmptyBlock?
    
    static func `default`() -> AlertButtonAction {
        AlertButtonAction(
            title: "Okay",
            style: .default,
            completion: nil
        )
    }
}
