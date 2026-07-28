//
//  RepositoryDetailServiceProtocol.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 詳細画面のスター操作の API 呼び出しを抽象化するプロトコル。
///
/// APIClient から必要なメソッドを切り出し、Repository の依存を最小化する。
protocol RepositoryDetailServiceProtocol {
    func fetchStarStatus(_ request: GetStarStatusRequest) async throws(APIError) -> NoContent
    func starRepository(_ request: StarRepositoryRequest) async throws(APIError) -> NoContent
    func unstarRepository(_ request: UnstarRepositoryRequest) async throws(APIError) -> NoContent
}

extension APIClient: RepositoryDetailServiceProtocol {
    func fetchStarStatus(_ request: GetStarStatusRequest) async throws(APIError) -> NoContent {
        try await send(request)
    }

    func starRepository(_ request: StarRepositoryRequest) async throws(APIError) -> NoContent {
        try await send(request)
    }

    func unstarRepository(_ request: UnstarRepositoryRequest) async throws(APIError) -> NoContent {
        try await send(request)
    }
}
