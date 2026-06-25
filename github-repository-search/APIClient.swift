//
//  APIClient.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/25.
//

import Foundation

final class APIClient {

    /// URLRequest を作成する。
    private func makeRequest() -> URLRequest? {

        // 1. URLComponents でベースURLを定義する。
        var components = URLComponents(string: "https://api.github.com/search/repositories")

        // 2. クエリパラメータを追加する。
        components?.queryItems = [
            URLQueryItem(name: "q", value: "Swift"),
        ]

        // 3. URLComponents から URL を取得する。
        // 正常に URL が作成できなかった場合は nil を返す。
        guard let url = components?.url else {
            return nil
        }

        // 4. URLRequest を作成する。
        var request = URLRequest(url: url)
        // GET メソッドを使用するので、httpMethod を "GET" に設定する。
        request.httpMethod = "GET"

        // 5. application/vnd.github+json を Accept ヘッダーに設定することが公式ドキュメントで推奨されているので、設定する。
        // https://docs.github.com/ja/rest/search/search?apiVersion=2026-03-10#search-repositories
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        // 設定は推奨されていないが、コードサンプルでは X-GitHub-Api-Version ヘッダーを設定しており、
        // APIのバージョンを指定することで将来的な互換性の問題を回避できる可能性があるため、設定しておく。
        request.setValue("2026-03-10", forHTTPHeaderField: "X-GitHub-Api-Version")

        // 5. 作成した URLRequest を返す。
        return request
    }
}
