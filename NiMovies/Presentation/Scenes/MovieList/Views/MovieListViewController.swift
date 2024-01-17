//
//  MovieListViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListView: AnyObject {
    func update()
    func appendItems(_ itemsCount: Int)
    func showError(message: String?)
    func showLoadingAnimation(completion: EmptyBlock?)
    func hideLoadingAnimation()
}

final class MovieListViewController: UIViewController, Alert {
    private struct Constant {
        static let sortButtonImageName = "arrow.up.and.down.text.horizontal"
        static let titleName = "Popular Movies"
        static let sectionInterGroupSpacing: CGFloat = 15
        static let movieItemHeightMultiplier: CGFloat = 1 / 2
        static let paginationValueUntilLoad: CGFloat = 500
        static let defaultSectionInset: CGFloat = 16
    }
    
    // MARK: - Properties -
    
    private var presenter: MovieListPresenter!
    private var loadingAnimationView: LoadingAnimationView!
    private lazy var isTableViewUpdating = true
    
    // MARK: - UI Components -
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.tintColor = .default
        searchController.searchBar.searchTextField.textColor = .default
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
        collectionView.register(
            MovieListFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
        )
        collectionView.register(MovieListCollectionViewCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        let image = UIImage(systemName: Constant.sortButtonImageName)
        button.image = image
        button.tintColor = .default
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
            let action = createSortTypeAction(type: type, controller: alertController)
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction.cancelAction())
        return alertController
    }()
    
    private lazy var backBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        button.tintColor = .default
        return button
    }()
    
    private lazy var collectionEmptyView: EmtpyStateView = {
        return EmtpyStateView()
    }()
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        presenter.initialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSortButton()
    }
    
    // MARK: - Internal -
    
    func inject(
        presenter: MovieListPresenter,
        loadingAnimationView: LoadingAnimationView
    ) {
        self.presenter = presenter
        self.loadingAnimationView = loadingAnimationView
    }
    
    func setupSortButton() {
        sortButton.isEnabled = presenter.getInternetConnectionStatus()
    }
}

// MARK: - Private -

private extension MovieListViewController {
    func setupNavigationBar() {
        title = Constant.titleName
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.navigationBar.barTintColor = .default
    }
    
    func setupView() {
        view.backgroundColor = .defaultBackground
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    func addEmptyViewIfNeeded() {
        let isNeeded = presenter.getMovieListCount() == .zero
        collectionView.backgroundView = isNeeded ? collectionEmptyView : nil
    }
    
    func createSortTypeAction(
        type: MovieListSortType,
        controller: UIAlertController
    ) -> UIAlertAction {
        let action = UIAlertAction(
            title: type.title,
            style: .default
        ) { [weak self] currentAction in
            guard let self,
                  type != presenter.sortType else {
                return
            }
            presenter.sortMovies(by: type)
            
            for action in controller.actions {
                action.isChecked = action == currentAction
            }
        }
        action.isChecked = type == presenter.sortType
        
        return action
    }
    
    @objc
    func didTapSortButton() {
        if let popoverController = sortActionSheet.popoverPresentationController {
            popoverController.barButtonItem = sortButton
        }
    
        present(sortActionSheet, animated: true, completion: nil)
    }
}

 // MARK: - MovieListView -

 extension MovieListViewController: MovieListView {
     func update() {
         collectionView.setContentOffset(.zero, animated: false)
         addEmptyViewIfNeeded()
         isTableViewUpdating = true
         
         UIView.animate(withDuration: .zero) {
             self.collectionView.reloadData()
         } completion: { _ in
             self.isTableViewUpdating = false
         }
     }
     
     func appendItems(_ itemsCount: Int) {
         let currentItemsCount = collectionView.numberOfItems(inSection: .zero)
         let newItemsCount = currentItemsCount + itemsCount
         let indexPaths = (currentItemsCount..<newItemsCount).map {
             IndexPath(item: $0, section: .zero)
         }
         collectionView.performBatchUpdates {
             collectionView.insertItems(at: indexPaths)
         }
     }
     
     func showError(message: String? = nil) {
         showAlert(message: message ?? AppConstant.defaultErrorMessage)
     }
     
     func showLoadingAnimation(completion: EmptyBlock? = nil) {
         loadingAnimationView.start(on: self, completion: completion)
     }
     
     func hideLoadingAnimation() {
         loadingAnimationView.hide()
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeue(
                ofKind: kind,
                viewType: MovieListFooterView.self,
                for: indexPath
            )
        default:
            return UICollectionReusableView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let boundsHeight = scrollView.bounds.size.height
        let distanceFromBottom = contentHeight - offsetY - boundsHeight

        if distanceFromBottom < Constant.paginationValueUntilLoad && !isTableViewUpdating {
            self.presenter.loadMoreMovies()
        }
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
        presenter.performMovieSearch(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.performMovieSearch(query: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.performMovieSearch(query: nil)
    }
}

// MARK: - UICollectionViewLayoutProvider -

extension MovieListViewController: UICollectionViewLayoutProvider {
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, environment in
            guard let self else {
                return nil
            }
            
            let item = createItem(height: .fractionalWidth(Constant.movieItemHeightMultiplier))
            let group = createVerticalGroup(with: [item])
            let section = createSection(with: group)
            
            addFooterIfNeeded(for: section)
            
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Constant.defaultSectionInset,
                leading: Constant.defaultSectionInset,
                bottom: Constant.defaultSectionInset,
                trailing: Constant.defaultSectionInset
            )
            section.interGroupSpacing = Constant.sectionInterGroupSpacing
            return section
        }
        return layout
    }
    
    private func addFooterIfNeeded(for section: NSCollectionLayoutSection) {
        let isConnectedToInternet = presenter.getInternetConnectionStatus()
        let isLoading = presenter.isRequestLoading
        let movieListCount = presenter.getMovieListCount()
        let isRequestAvailable = presenter.isRequestAvailable()

        if (isLoading || movieListCount > .zero)
            && isConnectedToInternet && isRequestAvailable {
            let footer = createFooter(
                ofKind: UICollectionView.elementKindSectionFooter,
                height: .absolute(50)
            )
            section.boundarySupplementaryItems = [footer]
        }
    }
}
