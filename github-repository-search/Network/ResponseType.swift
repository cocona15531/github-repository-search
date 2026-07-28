//
//  ResponseType.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/03.
//

import Foundation

/// API のレスポンスを表す型。RequestType と対になり、Generics の send の型制約として使う。
///
/// レスポンスはデコードのみ行うため Decodable に準拠する。
protocol ResponseType: Decodable {}

/// レスポンスボディを持たない成功レスポンス（204 No Content）を表す型。
///
/// star / unstar / スター状態確認のように、成功時にレスポンスボディが返らないエンドポイントの Response 型として使う。
struct NoContent: ResponseType {}
