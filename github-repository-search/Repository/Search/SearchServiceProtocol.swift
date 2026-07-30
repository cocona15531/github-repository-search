//
//  SearchServiceProtocol.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// リポジトリ検索の API 呼び出しを抽象化するプロトコル。
///
/// APIClient から必要なメソッドを切り出し、Repository の依存を最小化する。
protocol SearchServiceProtocol {
    func searchRepositories(_ request: SearchRepositoriesRequest) async throws(APIError) -> SearchResponse
}

extension APIClient: SearchServiceProtocol {
    func searchRepositories(_ request: SearchRepositoriesRequest) async throws(APIError) -> SearchResponse {
        try await send(request)
    }
}
