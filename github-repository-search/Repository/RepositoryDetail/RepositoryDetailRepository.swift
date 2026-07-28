//
//  RepositoryDetailRepository.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// リポジトリのスター操作に関するプロトコル。
protocol RepositoryDetailRepositoryProtocol {
    func isStarred(owner: String, name: String) async throws(APIError) -> Bool
    func star(owner: String, name: String) async throws(APIError)
    func unstar(owner: String, name: String) async throws(APIError)
}

/// リポジトリのスター操作に関するリポジトリ。
final class RepositoryDetailRepository: RepositoryDetailRepositoryProtocol {
    private let apiClient: any RepositoryDetailServiceProtocol

    init(apiClient: any RepositoryDetailServiceProtocol = APIClient(accessToken: Secrets.gitHubAccessToken)) {
        self.apiClient = apiClient
    }

    /// スター状態を取得する。204（スター済み）は true、404（未スター）は false に変換する。
    func isStarred(owner: String, name: String) async throws(APIError) -> Bool {
        do {
            _ = try await apiClient.fetchStarStatus(GetStarStatusRequest(owner: owner, repo: name))
            return true
        } catch {
            if case .unacceptable(statusCode: 404) = error { return false }
            throw error
        }
    }

    /// 指定リポジトリにスターを付ける。
    func star(owner: String, name: String) async throws(APIError) {
        _ = try await apiClient.starRepository(StarRepositoryRequest(owner: owner, repo: name))
    }

    /// 指定リポジトリのスターを外す。
    func unstar(owner: String, name: String) async throws(APIError) {
        _ = try await apiClient.unstarRepository(UnstarRepositoryRequest(owner: owner, repo: name))
    }
}
