//
//  ViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/05.
//

import Combine
import UIKit

final class ViewController: UIViewController {
    /// プロジェクト全体がデフォルトで MainActor 分離される設定になっており、Hashable は MainActor 限定として扱われてしまう。
    /// NSDiffableDataSourceSnapshot は Sendableな型を要求するため、nonisolated を付けて明示的に分離を外さないとビルドエラーになる。
    private nonisolated enum Section: Hashable {
        case main
    }

    private let viewModel = RepositorySearchViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "リポジトリを検索"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// 一覧の各行を縦に並べるだけのシンプルな CompositionalLayout を組み立てる。
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 16

        return UICollectionViewCompositionalLayout(section: section)
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
            }
            .store(in: &cancellables)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.didSubmitSearch(query: query)
    }
}

