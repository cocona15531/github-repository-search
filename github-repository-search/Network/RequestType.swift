//
//  RequestType.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/03.
//

import Foundation

/// API のリクエストを表す型。返す Response 型を associatedtype で結びつけ、send の戻り値を型で確定させる。
protocol RequestType {
    associatedtype Response: ResponseType
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

/// クエリを持たないリクエストは queryItems を書かなくてよい（自動で空配列を加える）。
extension RequestType {
    var queryItems: [URLQueryItem] { [] }
}
