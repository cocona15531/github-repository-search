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
    /// GitHub APIが422を返した場合。バリデーションエラーとスパム防止によるリクエスト拒否の両方を意味しうる。
    /// https://docs.github.com/ja/rest/search/search?apiVersion=2022-11-28#search-repositories
    case requestRejected
    /// GitHub APIのレートリミットを超過した場合（403 / 429）。
    /// https://docs.github.com/ja/rest/using-the-rest-api/rate-limits-for-the-rest-api
    case rateLimitExceeded
    /// GitHubのサービスが一時的に利用できない場合（503 Service Unavailable）。
    case serviceUnavailable
    /// 通信に失敗した場合（オフライン・タイムアウトなど）。
    case networkError
    /// リクエストがキャンセルされた場合。エラーとしてユーザーに提示しない。
    case cancellation
    case unknown
}

extension RepositorySearchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .requestRejected:
            return "検索条件をご確認いただくか、しばらく待ってから再度お試しください。"
        case .rateLimitExceeded:
            return "アクセスが集中しています。時間をおいて再度お試しください。"
        case .serviceUnavailable:
            return "GitHub のサービスが一時的に利用できません。時間をおいて再度お試しください。"
        case .networkError:
            return "通信に失敗しました。ネットワーク接続をご確認ください。"
        case .cancellation:
            return nil
        case .unknown:
            return "予期しないエラーが発生しました。"
        }
    }
}

/// リポジトリ検索に関するリポジトリプロトコル。
protocol RepositorySearchRepositoryProtocol {
    func searchRepositories(query: String) async throws(RepositorySearchError) -> [GitHubRepository]
}
