//
//  SearchRepository.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// リポジトリ検索に関するプロトコル。
protocol SearchRepositoryProtocol {
    func searchRepositories(query: String) async throws(APIError) -> [GitHubRepository]
}

/// リポジトリ検索に関するリポジトリ。
final class SearchRepository: SearchRepositoryProtocol {
    private let apiClient: any SearchServiceProtocol

    init(apiClient: any SearchServiceProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// SearchServiceProtocol 越しに APIClient を呼び、結果を DataModel に変換して返す。
    func searchRepositories(query: String) async throws(APIError) -> [GitHubRepository] {
        let response = try await apiClient.searchRepositories(SearchRepositoriesRequest(query: query))
        return response.repositories.map { RepositoryTranslator.translate(from: $0) }
    }
}
