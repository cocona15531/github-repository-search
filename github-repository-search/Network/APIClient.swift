//
//  APIClient.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/25.
//

import Foundation

final class APIClient {
    private let baseURL = URL(string: "https://api.github.com")!
    private let session: URLSession
    private let decoder = JSONDecoder()
    /// 認証が必要なエンドポイント（star 系）向けのアクセストークン。nil の場合は Authorization を付けない。
    private let accessToken: String?

    init(session: URLSession = .shared, accessToken: String? = nil) {
        self.session = session
        self.accessToken = accessToken
    }

    /// 任意の API リクエストを送信し、レスポンスをデコードして返す汎用メソッド。
    ///
    /// エンドポイントごとに処理を書かず、Request / Response 型を渡すだけで呼び出せる。
    func send<Request, Response>(_ request: Request) async throws(APIError) -> Response where Request: RequestType, Response: ResponseType {
        guard var urlRequest = URLRequest(request, baseURL: baseURL) else { throw .invalidURL }
        // application/vnd.github+json を Accept ヘッダーに設定することが公式ドキュメントで推奨されているので設定する。
        // https://docs.github.com/ja/rest/search/search?apiVersion=2026-03-10#search-repositories
        urlRequest.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        // 設定は推奨されていないが、コードサンプルでは X-GitHub-Api-Version ヘッダーを設定しており、
        // APIのバージョンを指定することで将来的な互換性の問題を回避できる可能性があるため設定しておく。
        // ここではコードサンプルに記載されている日付を使用する。
        urlRequest.setValue("2026-03-10", forHTTPHeaderField: "X-GitHub-Api-Version")
        // star 系 API は自分のアカウント権限が必要なので、トークンがあれば Authorization ヘッダーに付与する。
        if let accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw .urlSession(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            switch httpResponse.statusCode {
            case 403, 429:
                throw .rateLimitExceeded
            case 422:
                throw .requestRejected
            case 503:
                throw .serviceUnavailable
            default:
                throw .unacceptable(statusCode: httpResponse.statusCode)
            }
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw .decode(error)
        }
    }
}
