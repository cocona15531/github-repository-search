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

    /// 検索画面の状態。View はこれを購読して表示を切り替える。
    enum ViewState: Equatable {
        /// 検索前。
        case initial
        /// 検索中。
        case loading
        /// 検索結果あり。
        case content([RepositoryRowUIModel])
        /// 検索結果が0件。keyword は検索した文字列。
        case empty(keyword: String)
        /// 検索に失敗。String はエラーメッセージ。
        case error(String)
    }

    /// View からの検索文字列の送信口。
    private let searchQuerySubmitted = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let repository: any RepositorySearchRepositoryProtocol
    private var fetchedRepositories: [GitHubRepository] = []

    /// 検索画面の状態。View はこれを購読して表示に使う。
    @Published private(set) var state: ViewState = .initial
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
        state = .initial
    }

    /// セルが選択されたことをこの ViewModel に伝える。遷移先（Router）の決定をここで行う。
    func didSelectRepository(id: Int) {
        guard let repository = fetchedRepositories.first(where: { $0.id == id }) else { return }
        router = .detail(repository)
    }

    private func search(query: String) async {
        state = .loading
        do {
            fetchedRepositories = try await repository.searchRepositories(query: query)
            let repositories = fetchedRepositories.map { RepositorySearchUIModelTranslator.translate(from: $0) }
            state = repositories.isEmpty ? .empty(keyword: query) : .content(repositories)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
