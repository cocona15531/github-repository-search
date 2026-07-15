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
    /// View からの検索文字列の送信口。
    private let searchQuerySubmitted = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    private let repository: any RepositorySearchRepositoryProtocol

    /// 検索結果のリポジトリ一覧。View はこれを購読して表示に使う。
    @Published private(set) var repositories: [RepositoryRowUIModel] = []

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

    private func search(query: String) async {
        do {
            let fetchedRepositories = try await repository.searchRepositories(query: query)
            repositories = fetchedRepositories.map { RepositorySearchUIModelTranslator.translate(from: $0) }
        } catch {
            print(error.localizedDescription)
        }
    }
}
