//
//  APIClient.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/25.
//

import Foundation

final class APIClient {

    /// URLRequestを作成する。
    private func makeRequest() -> URLRequest? {

        // 1. URLComponents でベースURLを定義する。
        var components = URLComponents(string: "https://api.github.com/search/repositories")

        // 2. クエリパラメータを追加する。
        components?.queryItems = [
            URLQueryItem(name: "q", value: "Swift"),
        ]
        return nil
    }
}
