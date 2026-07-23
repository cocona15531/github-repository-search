//
//  GitHubRepository.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// API のレスポンス形状にも画面の表示形式にも依存しない、リポジトリという概念そのものを表す構造体。
struct GitHubRepository: Sendable, Equatable {
    /// GitHub のリポジトリを一意に識別する ID。
    let id: Int
    /// GitHub のリポジトリ名。
    let name: String
    /// GitHub のリポジトリの説明。リポジトリに説明が設定されていない場合は nil になる。
    let description: String?
    /// GitHub のリポジトリのスター数。
    let stargazersCount: Int
    /// GitHub のリポジトリの主要言語。設定されていない場合は nil になる。
    let language: String?
    /// GitHub のリポジトリのオーナー情報。
    let owner: Owner
    /// フォーク数。
    let forksCount: Int
    /// オープンな Issue 数。
    let openIssuesCount: Int
    /// 最後に push された日時（ISO8601 文字列）。存在しない場合は nil になる。
    let pushedAtString: String?
    /// リポジトリに設定されたトピック一覧。
    let topics: [String]

    struct Owner: Sendable, Equatable {
        /// オーナーのユーザー名。
        let login: String
        /// オーナーのアイコン画像のURL文字列。
        let avatarURLString: String
    }
}
