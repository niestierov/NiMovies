//
//  MovieDetailsViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import UIKit

protocol MovieDetailsView: AnyObject {
    func update(with title: String)
    func showError(message: String?)
}

final class MovieDetailsViewController: UIViewController, Alert {
    
    // MARK: - Properties -
    
    private var presenter: MovieDetailsPresenter!
    private var imageScreenView: ImageScreenView!
    private var youTubePlayerView: YouTubePlayerView!
    
    // MARK: - UI Components -
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableHeaderView = movieDetailsHeaderView
        tableView.register(MovieDetailsAttributeTableViewCell.self)
        tableView.register(MovieDetailsTrailerTableViewCell.self)
        tableView.register(MovieDetailsAttributeHeaderView.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var movieDetailsHeaderView: MovieDetailsHeaderView = {
        let headerHeightMultiplier: CGFloat = 1 / 3.6
        let headerHeight = view.frame.height * headerHeightMultiplier
        let headerWidth = view.frame.size.width
        let frame = CGRect(
            x: .zero,
            y: .zero,
            width: headerWidth,
            height: headerHeight
        )
        
        let movieDetailsHeader = MovieDetailsHeaderView(frame: frame)
        movieDetailsHeader.imageViewTapGestureHandler = { [weak self] in
            self?.openZoomPosterScreen()
        }
        movieDetailsHeader.isHidden = true
        return movieDetailsHeader
    }()
    
    private lazy var tableEmptyStateView: EmtpyStateView = {
        let view = EmtpyStateView()
        view.configure(title: AppConstant.defaultErrorMessage)
        return view
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        presenter.initialLoad()
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

// MARK: - MovieDetailsView -

extension MovieDetailsViewController: MovieDetailsView {
    func showError(message: String? = nil) {
        showAlert(message: message ?? AppConstant.defaultErrorMessage)
    }
    
    func update(with title: String) {
        updateTableView()
        
        UIView.animate(withDuration: 0) {
            self.title = title
            self.tableView.reloadData()
        }
    }

    func showYouTubePlayer(with videoKeys: [String]) {
        youTubePlayerView.showAndPlayVideo(with: videoKeys, on: self)
    }
}

// MARK: - Private -

private extension MovieDetailsViewController {
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func openZoomPosterScreen() {
        guard let posterUrl = presenter.getPosterUrl() else {
            return
        }
        imageScreenView.show(with: posterUrl, on: self)
    }
    
    func playTrailer() {
        guard let videoKeys = presenter.getVideoKeys() else {
            showError(message: AppConstant.defaultErrorMessage)
            return
        }
        youTubePlayerView.showAndPlayVideo(with: videoKeys, on: self)
    }
    
    func updateTableView() {
        if presenter.getSectionCount() == .zero {
            tableView.backgroundView = tableEmptyStateView
        } else {
            tableView.backgroundView = nil
            let imageUrlString = presenter.getHeader()?.backdrop ?? ""
            movieDetailsHeaderView.configure(image: imageUrlString)
            movieDetailsHeaderView.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource -

extension MovieDetailsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getSectionCount()
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let section = presenter.getSection(by: indexPath.section)
    
        switch section {
        case .attributeItem(let item):
            let cell = tableView.dequeue(
                MovieDetailsAttributeTableViewCell.self,
                for: indexPath
            )
            cell.selectionStyle = .none
            
            cell.configure(description: item.cell.description)
            return cell
            
        case .trailerItem(let item):
            let cell = tableView.dequeue(
                MovieDetailsTrailerTableViewCell.self,
                for: indexPath
            )
            cell.selectionStyle = .none
            cell.isHidden = !item.cell.isTrailerAvailable
            
            cell.trailerButtonTapHandler = { [weak self] in
                self?.playTrailer()
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate -

extension MovieDetailsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let section = presenter.getSection(by: section)
        
        switch section {
        case .attributeItem(let item):
            let header = tableView.dequeue(MovieDetailsAttributeHeaderView.self)
            header.configure(title: item.header.rawValue)
            return header
            
        case .trailerItem:
            return nil
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        let section = presenter.getSection(by: section)
        
        switch section {
        case .attributeItem:
            return UITableView.automaticDimension
        case .trailerItem:
            return .zero
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let section = presenter.getSection(by: indexPath.section)
        
        switch section {
        case .trailerItem(let item):
            return item.cell.isTrailerAvailable ? UITableView.automaticDimension : .zero
        case .attributeItem(_):
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = tableView.tableHeaderView as? MovieDetailsHeaderView else {
            return
        }
        header.updateOnViewDidScroll(scrollView)
    }
}
