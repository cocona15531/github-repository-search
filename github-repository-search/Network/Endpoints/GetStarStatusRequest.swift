//
//  GetStarStatusRequest.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 指定リポジトリを自分がスターしているかを確認する構造体。
struct GetStarStatusRequest: RequestType {
    typealias Response = NoContent
    var path: String { "/user/starred/\(owner)/\(repo)" }
    let method: HTTPMethod = .get
    let owner: String
    let repo: String
}
