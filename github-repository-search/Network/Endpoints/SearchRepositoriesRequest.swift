//
//  SearchRepositoriesRequest.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/03.
//

import Foundation

/// GitHub のリポジトリ検索 API のリクエストを表す構造体。
struct SearchRepositoriesRequest: RequestType {
    let path = "/search/repositories"
    let method: HTTPMethod = .get

    let query: String
    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "q", value: query)]
    }
}
