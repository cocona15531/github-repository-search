//
//  StarRepositoryRequest.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 指定リポジトリにスターを付ける API のリクエストを表す構造体。
struct StarRepositoryRequest: RequestType {
    var path: String { "/user/starred/\(owner)/\(repo)" }
    let method: HTTPMethod = .put
    let owner: String
    let repo: String
}
