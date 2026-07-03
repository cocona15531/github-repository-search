//
//  RequestType.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/03.
//

import Foundation

/// API のリクエストを表す型。ResponseType と対になり、Generics の send の型制約として使う。
protocol RequestType {
    static var path: String { get }
    static var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

/// クエリを持たないリクエストは queryItems を書かなくてよい（自動で空配列を加える）。
extension RequestType {
    var queryItems: [URLQueryItem] { [] }
}
