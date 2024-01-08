//
//  MovieDetailsViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import UIKit

protocol MovieDetailsView: AnyObject {
    func showError(message: String?)
    func update(with movie: MovieDetailsViewState.Movie)
    func updateTrailerButton(isHidden: Bool)
}

final class MovieDetailsViewController: UIViewController, Alert {
    private struct Constant {
        static let defaultInset: CGFloat = 20
        static let trailerButtonImageName = "play.circle.fill"
    }
    
    // MARK: - Properties -
    
    private var presenter: MovieDetailsPresenter!
    private var imageScreenView: ImageScreenView!
    private var youTubePlayerView: YouTubePlayerView!
    
    // MARK: - UI Components -
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var trailerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var trailerPrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch latest trailer:"
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trailerButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: Constant.trailerButtonImageName),
            for: .normal
        )
        button.isHidden = true
        button.tintColor = .black
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapTrailerButton), for: .touchUpInside)
        button.imageView?.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, radius: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Title")
        stackView.contentText = "Title unknown."
        return stackView
    }()
    
    private lazy var descriptionStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Descriprion")
        stackView.contentText = "It looks like there is no description."
        return stackView
    }()
    
    private lazy var releaseDateStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Release date")
        stackView.contentText = "Release unknown."
        return stackView
    }()
    
    private lazy var ratingStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Rating")
        stackView.contentText = "Rating unknown"
        return stackView
    }()
    
    private lazy var productionStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Production")
        stackView.contentText = "Production unknown."
        return stackView
    }()
    
    private lazy var genresStackView: MovieDetailsStackViewItem = {
        let stackView = MovieDetailsStackViewItem(title: "Genres")
        stackView.contentText = "Genres unknown"
        return stackView
    }()
    
    private lazy var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.applyShadow(radius: 8)
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapImageView)
        )
        imageView.addGestureRecognizer(tapGesture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        presenter.initialLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        trailerButton.applyRoundedCorners(radius: trailerButton.frame.width / 2)
    }
    
    // MARK: - Internal -
    
    func inject(
        presenter: MovieDetailsPresenter,
        imageScreenView: ImageScreenView,
        youTubePlayerView: YouTubePlayerView
    ) {
        self.presenter = presenter
        self.imageScreenView = imageScreenView
        self.youTubePlayerView = youTubePlayerView
    }
}

// MARK: - Private -

private extension MovieDetailsViewController {
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(movieImageView)
        scrollView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(trailerStackView)
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(genresStackView)
        mainStackView.addArrangedSubview(releaseDateStackView)
        mainStackView.addArrangedSubview(descriptionStackView)
        mainStackView.addArrangedSubview(ratingStackView)
        mainStackView.addArrangedSubview(productionStackView)
        
        trailerStackView.addArrangedSubview(trailerPrefixLabel)
        trailerStackView.addArrangedSubview(trailerButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            movieImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            movieImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            movieImageView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.3
            ),
            
            mainStackView.topAnchor.constraint(
                equalTo: movieImageView.bottomAnchor,
                constant: 5
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: -Constant.defaultInset
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Constant.defaultInset
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Constant.defaultInset
            ),
            
            trailerButton.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: 0.16
            ),
            trailerButton.heightAnchor.constraint(equalTo: trailerButton.widthAnchor),
        ])
        view.layoutIfNeeded()
    }
    
    @objc
    func didTapImageView() {
        guard let posterUrl = presenter.getPosterUrl() else {
            return
        }
        imageScreenView.show(with: posterUrl, on: self)
    }
    
    @objc
    func didTapTrailerButton() {
        guard let videoKeys = presenter.getVideoKeys() else {
            showError(message: AppConstant.defaultErrorMessage)
            return
        }
        youTubePlayerView.showAndPlayVideo(with: videoKeys, on: self)
    }
}

extension MovieDetailsViewController: MovieDetailsView {
    func showError(message: String?) {
        showAlert(message: message ?? AppConstant.defaultErrorMessage)
    }
    
    func update(with movie: MovieDetailsViewState.Movie) {
        movieImageView.setImage(
            with: movie.backdropUrlString,
            placeholder: UIImage(named: AppConstant.moviePosterPlaceholderName)
        )
        
        titleStackView.contentText = movie.title
        releaseDateStackView.contentText = movie.releaseDate
        genresStackView.contentText = movie.genres
        descriptionStackView.contentText = movie.overview
        ratingStackView.contentText = movie.voteAverage
        productionStackView.contentText = movie.country
    }
    
    func updateTrailerButton(isHidden: Bool) {
        trailerButton.isHidden = isHidden
    }
    
    func showYouTubePlayer(with videoKeys: [String]) {
        youTubePlayerView.showAndPlayVideo(with: videoKeys, on: self)
    }
}
