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
    /// GitHub のリポジトリ名。
    let name: String
    /// GitHub のリポジトリの説明。nil の場合もある。
    let description: String?
    /// GitHub のリポジトリのスター数。
    let stargazersCount: Int

    /// JSON のキーと構造体のプロパティ名が異なるのでマッピングを行う。
    enum CodingKeys: String, CodingKey {
        case name
        case description
        /// stargazersCount は JSON では "stargazers_count" というキーで表されるため、対応づけを行う。
        case stargazersCount = "stargazers_count"
    }
}
