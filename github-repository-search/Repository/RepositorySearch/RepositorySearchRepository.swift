//
//  RepositorySearchRepository.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// リポジトリ検索に関するリポジトリ。
final class RepositorySearchRepository: RepositorySearchRepositoryProtocol {
    private let apiClient: any RepositorySearchServiceProtocol

    init(apiClient: any RepositorySearchServiceProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// RepositorySearchServiceProtocol 越しに APIClient を呼び、結果を DataModel に変換して返す。
    func searchRepositories(query: String) async throws(RepositorySearchError) -> [GitHubRepository] {
        do {
            let response = try await apiClient.searchRepositories(SearchRepositoriesRequest(query: query))
            return response.repositories.map { RepositoryTranslator.translate(from: $0) }
        } catch {
            throw .apiError(error.localizedDescription)
        }
    }
}
