//
//  Repository.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/26.
//

import Foundation

/// GitHub のリポジトリ検索 API のレスポンスを表す構造体。
///
/// Decodable プロトコルに準拠しているので、JSON から自動的にデコードできる。
struct SearchResponse: Decodable {
    /// レポジトリ情報を含んだ配列。
    let items: [Repository]
}
struct Repository: Decodable {
  }
