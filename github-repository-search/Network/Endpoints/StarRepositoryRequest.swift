//
//  StarRepositoryRequest.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 指定リポジトリにスターを付ける API のリクエストを表す構造体。
struct StarRepositoryRequest: RequestType {
    let owner: String
    let repo: String
    let method: HTTPMethod = .put
    var path: String { "/user/starred/\(owner)/\(repo)" }
}
