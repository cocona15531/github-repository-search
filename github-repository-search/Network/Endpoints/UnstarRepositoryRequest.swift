//
//  UnstarRepositoryRequest.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 指定リポジトリのスターを外す API のリクエストを表す構造体。成功時は 204（レスポンスボディなし）が返る。
struct UnstarRepositoryRequest: RequestType {
    typealias Response = NoContent
    var path: String { "/user/starred/\(owner)/\(repo)" }
    let method: HTTPMethod = .delete
    let owner: String
    let repo: String
}
