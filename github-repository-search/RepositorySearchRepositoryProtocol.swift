//
//  RepositorySearchRepositoryProtocol.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// リポジトリ検索で発生するエラー。
///
/// Repository 層で APIError から変換され、ViewModel 層で表示に使用する。
enum RepositorySearchError: Error {
    case apiError(String)
}

extension RepositorySearchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        }
    }
}

/// リポジトリ検索に関するリポジトリプロトコル。
protocol RepositorySearchRepositoryProtocol {
    func searchRepositories(query: String) async throws(RepositorySearchError) -> [GitHubRepository]
}
