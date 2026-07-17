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
            throw Self.translate(from: error)
        }
    }

    /// APIError を RepositorySearchError に変換する。
    ///
    /// URLSession の CancellationError は明示的に .cancellation に変換し、
    /// ステータスコードから GitHub API で代表的なエラーを判別する。
    private static func translate(from error: APIError) -> RepositorySearchError {
        switch error {
        case .urlSession(let underlyingError) where underlyingError is CancellationError:
            return .cancellation
        case .urlSession:
            return .networkError
        case .unacceptable(let statusCode):
            switch statusCode {
            case 403, 429:
                return .rateLimitExceeded
            case 422:
                return .requestRejected
            case 503:
                return .serviceUnavailable
            default:
                return .unknown
            }
        default:
            return .unknown
        }
    }
}
