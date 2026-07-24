//
//  RepositorySearchViewModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/19.
//

import Combine
import Foundation

@MainActor
final class RepositorySearchViewModel {
    /// この画面から遷移しうる画面を表す。View はこれを購読して遷移を行う。
    enum Router: Equatable {
        case detail(GitHubRepository)
    }

    /// View からの検索文字列の送信口。
    private let searchQuerySubmitted = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let repository: any RepositorySearchRepositoryProtocol
    private var fetchedRepositories: [GitHubRepository] = []

    /// 検索結果のリポジトリ一覧。View はこれを購読して表示に使う。
    @Published private(set) var repositories: [RepositoryRowUIModel] = []
    /// 画面遷移のトリガー。セル選択時に遷移先が入る。
    @Published private(set) var router: Router?

    init(repository: any RepositorySearchRepositoryProtocol = RepositorySearchRepository()) {
        self.repository = repository

        searchQuerySubmitted
            .sink { [weak self] query in
                guard let self else { return }
                Task { await self.search(query: query) }
            }
            .store(in: &cancellables)
    }

    /// 検索が実行されたことをこの ViewModel に伝える。
    func didSubmitSearch(query: String) {
        searchQuerySubmitted.send(query)
    }

    func didClearSearch() {
        fetchedRepositories = []
        repositories = []
    }

    /// 指定 id の DataModel を返す。セル選択時に詳細画面へ渡す元データを引くために使う。
    func repository(withId id: Int) -> GitHubRepository? {
        fetchedRepositories.first { $0.id == id }
    }

    private func search(query: String) async {
        do {
            fetchedRepositories = try await repository.searchRepositories(query: query)
            repositories = fetchedRepositories.map { RepositorySearchUIModelTranslator.translate(from: $0) }
        } catch {
            print(error.localizedDescription)
        }
    }
}
