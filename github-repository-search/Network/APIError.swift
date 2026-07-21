//
//  APIError.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/29.
//

import Foundation

enum APIError: Error {
    /// URL の作成に失敗した場合のエラー。
    case invalidURL
    /// レスポンスとして解釈できなかった場合のエラー。
    case invalidResponse
    /// GitHub APIが422を返した場合のエラー。バリデーションエラーとスパム防止によるリクエスト拒否の両方を意味しうる。
    /// https://docs.github.com/ja/rest/search/search?apiVersion=2022-11-28#search-repositories
    case requestRejected
    /// GitHub APIのレートリミットを超過した場合のエラー（403 / 429）。
    /// https://docs.github.com/ja/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#exceeding-the-rate-limit
    case rateLimitExceeded
    /// GitHubのサービスが一時的に利用できない場合のエラー（503 Service Unavailable）。
    case serviceUnavailable
    /// 上記以外でステータスコードが 2xx 以外だった場合のエラー。
    case unacceptable(statusCode: Int)
    /// URLSession でのエラー。
    case urlSession(Error)
    /// デコードに失敗した場合のエラー。
    case decode(Error)
}

/// APIError を LocalizedError に準拠させ、エラー種別ごとの表示文言を提供する。
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL が無効です。"
        case .invalidResponse:
            return "レスポンスが無効です。"
        case .requestRejected:
            return "検索条件をご確認いただくか、しばらく待ってから再度お試しください。"
        case .rateLimitExceeded:
            return "アクセスが集中しています。時間をおいて再度お試しください。"
        case .serviceUnavailable:
            return "GitHub のサービスが一時的に利用できません。時間をおいて再度お試しください。"
        case .unacceptable(let statusCode):
            return "ステータスコードが 2xx 以外でした: \(statusCode)"
        case .urlSession(let error):
            return "API 呼び出し中にエラーが発生しました: \(error.localizedDescription)"
        case .decode(let error):
            return "デコードに失敗しました: \(error.localizedDescription)"
        }
    }
}
