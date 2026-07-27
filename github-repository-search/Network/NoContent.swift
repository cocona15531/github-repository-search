//
//  NoContent.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/27.
//

import Foundation

/// 本文を持たない成功レスポンス（204 No Content）を表す型。
///
/// star / unstar / スター状態確認のように、成功時に本文が返らないエンドポイントの Response 型として使う。
struct NoContent: ResponseType {}
