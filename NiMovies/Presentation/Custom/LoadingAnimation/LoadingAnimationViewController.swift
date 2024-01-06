//
//  LoadingAnimation.swift
//  NiMovies
//
//  Created by Denys Niestierov on 05.01.2024.
//

import UIKit
import Lottie

protocol LoadingAnimationView: AnyObject {
    func start(
        on parentViewController: UIViewController,
        completion: EmptyBlock?
    )
    func hide()
}

final class LoadingAnimationViewController: UIViewController {
    
    // MARK: - UI Components -
    
    private lazy var loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: AppConstant.initialLoadingAnimationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension LoadingAnimationViewController {
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(loadingAnimationView)
        
        NSLayoutConstraint.activate([
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2),
            loadingAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),
        ])
    }
}

extension LoadingAnimationViewController: LoadingAnimationView {
    func start(
        on parentViewController: UIViewController,
        completion: EmptyBlock? = nil
    ) {
        parentViewController.addChild(self)
        parentViewController.view.addSubview(view)

        loadingAnimationView.play() { completed in
            completion?()
        }
    }
    
    func hide() {
        loadingAnimationView.stop()
        
        UIView.animate(withDuration: 0.5) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
}
