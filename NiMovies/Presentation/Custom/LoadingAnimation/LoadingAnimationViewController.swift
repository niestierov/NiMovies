//
//  LoadingAnimationViewController.swift
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
    func continueWithLoop()
    func hide()
}

final class LoadingAnimationViewController: UIViewController {
    
    // MARK: - UI Components -
    
    private lazy var loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: AppConstant.initialLoadingAnimationName)
        animationView.contentMode = .scaleAspectFit
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
        on parent: UIViewController,
        completion: EmptyBlock? = nil
    ) {
        parent.addChild(self)
        parent.view.addSubview(view)

        loadingAnimationView.loopMode = .playOnce
        loadingAnimationView.play() { completed in
            completion?()
        }
    }
    
    func continueWithLoop() {
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.play()
    }
    
    func hide() {
        loadingAnimationView.stop()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
}
