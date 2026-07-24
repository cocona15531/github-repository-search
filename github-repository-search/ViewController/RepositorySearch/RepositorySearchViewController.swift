//
//  RepositorySearchViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/05.
//

import Combine
import UIKit

final class RepositorySearchViewController: UIViewController {
    /// プロジェクト全体がデフォルトで MainActor 分離される設定になっており、Hashable は MainActor 限定として扱われてしまう。
    /// NSDiffableDataSourceSnapshot は Sendableな型を要求するため、nonisolated を付けて明示的に分離を外さないとビルドエラーになる。
    private nonisolated enum Section: Hashable {
        case main
    }

    private let viewModel = RepositorySearchViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "リポジトリを検索"
        return searchController
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "検索してみましょう"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GitHub内のリポジトリが検索できます"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateTitleLabel, emptyStateSubtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        // iOS 26 では検索バーの配置がデフォルトで画面下部になるため、
        // OS間で見た目が変わらないようナビゲーションバーを画面上部に固定する。
        if #available(iOS 26.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        setupViews()
        collectionView.delegate = self
        bindViewModel()
    }

    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateStackView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    /// 先頭・末尾の角丸やセルの区切り線が標準で提供される insetGrouped スタイルのリストレイアウトを組み立てる。
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    /// RepositoryCell を RepositoryRowUIModel で設定する DiffableDataSource を組み立てる。
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, RepositoryRowUIModel> {
        let cellRegistration = UICollectionView.CellRegistration<RepositoryCell, RepositoryRowUIModel> { cell, _, repository in
            cell.configure(with: repository)
        }

        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, repository in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: repository)
        }
    }

    /// ViewModelの検索結果を購読し、スナップショットを作り直して一覧に反映する。
    ///
    /// 新旧のスナップショットの差分を DiffableDataSource が自動計算するため、
    /// reloadData() を呼ばずとも変化した行だけがアニメーション付きで更新される。
    private func bindViewModel() {
        viewModel.$repositories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] repositories in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, RepositoryRowUIModel>()
                snapshot.appendSections([.main])
                snapshot.appendItems(repositories, toSection: .main)
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.emptyStateStackView.isHidden = !repositories.isEmpty
            }
            .store(in: &cancellables)
    }
}

extension RepositorySearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.didSubmitSearch(query: query)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty else { return }
        viewModel.didClearSearch()
    }
}

extension RepositorySearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let rowUIModel = dataSource.itemIdentifier(for: indexPath),
              let repository = viewModel.repository(withId: rowUIModel.id) else { return }
        let detailViewController = RepositoryDetailViewControllerProvider.build(repository: repository)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
