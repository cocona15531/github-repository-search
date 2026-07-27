//
//  NoContent.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// レスポンスボディを持たない成功レスポンス（204 No Content）を表す型。
///
/// star / unstar / スター状態確認のように、成功時にレスポンスボディが返らないエンドポイントの Response 型として使う。
struct NoContent: ResponseType {}
