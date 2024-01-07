//
//  ImageScreenViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 07.01.2024.
//

import UIKit

protocol ImageScreenView {
    func show(
        with urlString: String,
        on parent: UIViewController
    )
    func show(
        with image: UIImage,
        on parent: UIViewController
    )
}

final class ImageScreenViewController: UIViewController {
    
    // MARK: - UI Components -
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupComponents()
    }
}

// MARK: - ImageScreenView -

extension ImageScreenViewController: ImageScreenView {
    func show(
        with urlString: String,
        on parent: UIViewController
    ) {
        imageView.setImage(with: urlString)
        present(on: parent)
    }
    
    func show(
        with image: UIImage,
        on parent: UIViewController
    ) {
        imageView.image = image
        present(on: parent)
    }
}

// MARK: - UIScrollViewDelegate -

extension ImageScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK: - Private -

private extension ImageScreenViewController {
    func setupView() {
        let swipeGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeDownGestureHandler(_:))
        )
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        view.backgroundColor = .black
    }
    
    func setupComponents() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }
    
    func present(on parent: UIViewController) {
        modalPresentationStyle = .fullScreen
        parent.present(self, animated: true, completion: nil)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func swipeDownGestureHandler(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            dismiss()
        }
    }
}
