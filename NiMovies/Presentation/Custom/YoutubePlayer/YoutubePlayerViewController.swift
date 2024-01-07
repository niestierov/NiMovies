//
//  YouTubePlayerViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 07.01.2024.
//

import YouTubeiOSPlayerHelper

protocol YouTubePlayerView {
    func showAndPlayVideo(
        with keys: [String],
        on parent: UIViewController
    )
}

final class YouTubePlayerViewController: UIViewController {
    
    // MARK: - Properties -
    
    private var videoKeys: [String]?
    
    // MARK: - UI Components -
    
    private lazy var playerView: YTPlayerView = {
        let playerView = YTPlayerView()
        playerView.delegate = self
        playerView.backgroundColor = .clear
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupComponents()
    }
}

// MARK: - YouTubePlayerView -

extension YouTubePlayerViewController: YouTubePlayerView {
    func showAndPlayVideo(
        with keys: [String],
        on parent: UIViewController
    ) {
        videoKeys = keys
        present(on: parent)
        
        view.showActivityIndicator(color: .white)
        loadNextVideo()
    }
}

// MARK: - Private -

private extension YouTubePlayerViewController {
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
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadNextVideo() {
        guard let firstKey = videoKeys?.first else {
            return
        }
        playerView.load(withVideoId: firstKey)
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

extension YouTubePlayerViewController: YTPlayerViewDelegate {
    func playerView(
        _ playerView: YTPlayerView, 
        didChangeTo state: YTPlayerState
    ) {
        if state == .unstarted {
            self.videoKeys?.removeFirst()
            loadNextVideo()
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        view.hideActivityIndicator()
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        .clear
    }
}
