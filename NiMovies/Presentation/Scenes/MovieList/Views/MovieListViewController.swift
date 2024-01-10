//
//  MovieListViewController.swift
//  NiMovies
//
//  Created by Denys Niestierov on 25.12.2023.
//

import UIKit

protocol MovieListView: AnyObject {
    func update()
    func update(with indexPaths: [IndexPath])
    func showError(message: String?)
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
        static let paginationValueUntilLoad = 3
    }
    
    // MARK: - Properties -
    
    private var presenter: MovieListPresenter!
    private var loadingAnimationView: LoadingAnimationView!
    
    // MARK: - UI Components -
    
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
    
    private lazy var backBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        return button
    }()

    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        presenter.initialLoad()
    }
    
    // MARK: - Internal -
    
    func inject(
        presenter: MovieListPresenter,
        loadingAnimationView: LoadingAnimationView
    ) {
        self.presenter = presenter
        self.loadingAnimationView = loadingAnimationView
    }
    
    private lazy var emptyViewStateLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results found."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
     
// MARK: - Private -

private extension MovieListViewController {
    func setupNavigationBar() {
        title = Constant.titleName
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
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
     
 // MARK: - MovieListView -

 extension MovieListViewController: MovieListView {
     func update(with indexPaths: [IndexPath]) {
         collectionView.insertItems(at: indexPaths)
     }
     
     func update() {
         emptyViewStateLabel.isHidden = presenter.getMovieListCount() == .zero
         
         scrollToTop(animated: true)
         collectionView.reloadData()
     }
     
     func showError(message: String?) {
         showAlert(message: message ?? AppConstant.defaultErrorMessage)
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
         let continueWithoutInternet = AlertButtonAction.default()
         
         showAlert(
             message: AppConstant.noInternetConnectionErrorMessage,
             actions: [openAppSettingAction, continueWithoutInternet]
         )
     }
     
     func updateRequestStartedState() {
         collectionView.showActivityIndicator()
     }
     
     func updateRequestEndedState() {
         collectionView.hideActivityIndicator()
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
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, environment in
            guard let self else {
                return nil
            }
            
            let item = createItem(height: .absolute(Constant.movieItemHeight))
            let group = createVerticalGroup(with: [item])
            let section = createSection(with: group)
            
            let footerHeight: CGFloat = presenter.getMovieListCount() == 0 ? 0 : 50
            let footer = createFooter(
                ofKind: UICollectionView.elementKindSectionFooter,
                height: .absolute(footerHeight)
            )
            
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 16,
                bottom: 16,
                trailing: 16
            )
            section.interGroupSpacing = Constant.sectionInterGroupSpacing
            section.boundarySupplementaryItems = [footer]
            
            section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                guard let self,
                      let indexPath = items.last?.indexPath,
                      indexPath.item >= presenter.getMovieListCount() - Constant.paginationValueUntilLoad else {
                    return
                }
                
                presenter.loadMoreMovies()
            }
            return section
        }
        return layout
    }
}
