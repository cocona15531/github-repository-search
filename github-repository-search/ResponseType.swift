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
