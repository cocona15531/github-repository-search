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
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
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

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
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

    /// ViewModel の状態を購読し、状態ごとに一覧・ローディング・空表示を切り替える。
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .initial:
                    self.loadingIndicator.stopAnimating()
                    self.applyItems([])
                    self.showEmptyState(title: "検索してみましょう", subtitle: "GitHub内のリポジトリが検索できます")
                case .loading:
                    self.loadingIndicator.startAnimating()
                    self.emptyStateStackView.isHidden = true
                    self.applyItems([])
                case .content(let repositories):
                    self.loadingIndicator.stopAnimating()
                    self.emptyStateStackView.isHidden = true
                    self.applyItems(repositories)
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.applyItems([])
                    self.showEmptyState(title: "エラーが発生しました", subtitle: message)
                }
            }
            .store(in: &cancellables)

        viewModel.$router
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] router in
                guard let self else { return }
                switch router {
                case .detail(let repository):
                    let vc = RepositoryDetailViewControllerProvider.build(repository: repository)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: &cancellables)
    }

    /// 一覧に表示する行を差分更新する。
    ///
    /// 新旧スナップショットの差分を DiffableDataSource が自動計算するため、変化した行だけがアニメーション付きで更新される。
    private func applyItems(_ items: [RepositoryRowUIModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RepositoryRowUIModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    /// 中央の空表示にタイトル・サブタイトルを設定して表示する。
    private func showEmptyState(title: String, subtitle: String) {
        emptyStateTitleLabel.text = title
        emptyStateSubtitleLabel.text = subtitle
        emptyStateStackView.isHidden = false
    }
}

extension RepositorySearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else { return }
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
        guard let rowUIModel = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didSelectRepository(id: rowUIModel.id)
    }
}
