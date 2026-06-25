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
        return nil
    }
}
