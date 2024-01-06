//
//  UIImageView+ImageService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 26.12.2023.
//

import UIKit

extension UIImageView {
    func setImage(
        with url: URL,
        placeholder: UIImage? = nil,
        completion: EmptyBlock? = nil
    ) {
        ImageService.shared.setImage(
            with: url,
            for: self,
            placeholder: placeholder,
            completion: completion
        )
    }

    func setImage(
        with urlString: String,
        placeholder: UIImage? = nil,
        completion: EmptyBlock? = nil
    ) {
        ImageService.shared.setImage(
            string: urlString,
            for: self,
            placeholder: placeholder,
            completion: completion
        )
    }
    
    func prepareForReload() {
        ImageService.shared.cancelKfDownloadTask(for: self)
        self.image = nil
    }
}
