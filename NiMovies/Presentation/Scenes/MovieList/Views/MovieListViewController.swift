//
//  MovieListViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListView: AnyObject {
    func update()
    func initialUpdate()
    func showError(message: String?)
    func showScrollToTop(_ isVisible: Bool)
    func showLoadingAnimation(completion: EmptyBlock?)
    func continueLoadingAnimation()
    func hideLoadingAnimation()
    func showNoInternetConnectionError()
    func updateRequestStartedState()
    func updateRequestEndedState()
}

final class MovieListViewController: UIViewController, Alert {
    private struct Constant {
        static let scrollToTopButtonImageName = "arrow.up"
        static let sortButtonImageName = "arrow.up.and.down.text.horizontal"
        static let titleName = "Popular Movies"
        static let sectionInterGroupSpacing: CGFloat = 15
        static let movieItemHeight: CGFloat = 200
    }
    
    // MARK: - Properties -
    
    private var presenter: MovieListPresenter!
    
    // MARK: - UI Components -
    
    private var loadingAnimationView: LoadingAnimationView!
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Search for a movie"
        searchController.searchBar.delegate = self
        searchController.searchBar.spellCheckingType = .no
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: makeCompositionalLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieListCollectionViewCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var scrollToTopButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(didTapScrollToTop),
            for: .touchUpInside
        )
        button.isHidden = true
        button.applyShadow(offset: CGSize(width: 0, height: 2))
        button.backgroundColor = .white
        button.tintColor = .black
        let image = UIImage(systemName: Constant.scrollToTopButtonImageName)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        let image = UIImage(systemName: Constant.sortButtonImageName)
        button.image = image
        button.tintColor = .black
        button.target = self
        button.action = #selector(didTapSortButton)
        return button
    }()
    
    private lazy var sortActionSheet: UIAlertController = {
        let alertController = UIAlertController(
            title: "Sort By",
            message: nil,
            preferredStyle: .actionSheet
        )
        MovieListSortType.allCases.forEach { type in
            let action = UIAlertAction(
                title: type.title,
                style: .default
            ) { [weak self] currentAction in
                guard let self, type != presenter.sortType else {
                    return
                }
                presenter.sortMovies(by: type)
                
                for action in alertController.actions {
                    action.isChecked = action == currentAction
                }
            }
            action.isChecked = type == presenter.sortType
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction.cancelAction())
        return alertController
    }()

    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        presenter.initialLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToTopButton.applyRoundedCorners(radius: scrollToTopButton.frame.width / 2)
    }
    
    // MARK: - Internal -
    
    func inject(
        presenter: MovieListPresenter,
        loadingAnimationView: LoadingAnimationView
    ) {
        self.presenter = presenter
        self.loadingAnimationView = loadingAnimationView
    }
}

// MARK: - MovieListView -

extension MovieListViewController: MovieListView {
    func update() {
        collectionView.reloadData()
    }
    
    func initialUpdate() {
        scrollToTop(animated: true)
    }
    
    func showError(message: String?) {
        showAlert(message: message ?? AppConstant.defaultErrorMessage)
    }
    
    func showScrollToTop(_ isVisible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.scrollToTopButton.alpha = isVisible ? 1 : 0
        } completion: { _ in
            self.scrollToTopButton.isHidden = !isVisible
        }
    }
    
    func showLoadingAnimation(completion: EmptyBlock? = nil) {
        loadingAnimationView.start(on: self, completion: completion)
    }
    
    func hideLoadingAnimation() {
        loadingAnimationView.hide()
    }
    
    func continueLoadingAnimation() {
        loadingAnimationView.continueWithLoop()
    }
    
    func showNoInternetConnectionError() {
        let openAppSettingAction = AlertButtonAction(
            title: "Open settings",
            style: .default
        ) {
            UIApplication.openAppSettings()
        }
    
        showAlert(
            message: AppConstant.noInternetConnectionMessage,
            actions: [openAppSettingAction]
        )
    }
    
    func updateRequestStartedState() {
        collectionView.showActivityIndicator()
    }
    
    func updateRequestEndedState() {
        collectionView.hideActivityIndicator()
    }
}

// MARK: - Private -

private extension MovieListViewController {
    func setupNavigationBar() {
        title = Constant.titleName
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = sortButton
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(scrollToTopButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            scrollToTopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollToTopButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            scrollToTopButton.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: 1/7
            ),
            scrollToTopButton.heightAnchor.constraint(equalTo: scrollToTopButton.widthAnchor),
        ])
    }
    
    func scrollToTop(animated: Bool) {
        collectionView.setContentOffset(.zero, animated: animated)
    }
    
    @objc
    func didTapScrollToTop() {
        scrollToTop(animated: true)
    }
    
    @objc
    func didTapSortButton() {
        present(sortActionSheet, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate -

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.didSelectMovie(at: indexPath.item)
    }
}

extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        presenter.getMovieListCount()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(
            cellType: MovieListCollectionViewCell.self,
            at: indexPath
        )
        guard let movie = presenter.getMovie(at: indexPath.item) else {
            return cell
        }
        
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UISearchBarDelegate -

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchMovies(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchMovies(query: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchMovies(query: nil)
    }
}

// MARK: - UICollectionViewLayoutProvider -

extension MovieListViewController: UICollectionViewLayoutProvider {
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, environment in
            guard let self else {
                return nil
            }
            
            let item = createItem(height: .absolute(Constant.movieItemHeight))
            let group = createVerticalGroup(with: [item])
            let section = createSection(with: group)
            
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 16,
                bottom: 16,
                trailing: 16
            )
            section.interGroupSpacing = Constant.sectionInterGroupSpacing
            
            section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                guard let self, let indexPath = items.last?.indexPath else {
                    return
                }
                presenter.didScrollView(at: indexPath.row)
            }
            
            return section
        }
        
        return layout
    }
}
