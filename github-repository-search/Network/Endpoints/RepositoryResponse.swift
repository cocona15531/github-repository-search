//
//  RepositoryResponse.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/26.
//

import Foundation

/// GitHub のリポジトリ検索 API のレスポンスを表す構造体。
struct SearchResponse: ResponseType {
    /// リポジトリ情報を含んだ配列。
    let repositories: [RepositoryResponse]

    /// JSON のキーと構造体のプロパティ名が異なるのでマッピングを行う。
    enum CodingKeys: String, CodingKey {
        case repositories = "items"
    }
}

/// GitHub のリポジトリ 1 件分の情報を表す構造体。
struct RepositoryResponse: Decodable {
    /// GitHub のリポジトリを一意に識別するID。
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
    /// リポジトリに設定されたトピック一覧。存在しない場合は nil になる。
    let topics: [String]?

    /// GitHub のリポジトリのオーナー（ユーザー or Organization）を表す構造体。
    struct Owner: Decodable {
        /// オーナーのユーザー名。
        let login: String
        /// オーナーのアイコン画像のURL文字列。
        let avatarURLString: String

        /// JSON のキーと構造体のプロパティ名が異なるのでマッピングを行う。
        enum CodingKeys: String, CodingKey {
            case login
            /// avatarURLString は JSON では "avatar_url" というキーで表されるため、対応づけを行う。
            case avatarURLString = "avatar_url"
        }
    }

    /// JSON のキーと構造体のプロパティ名が異なるのでマッピングを行う。
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case language
        case owner
        case topics
        /// stargazersCount は JSON では "stargazers_count" というキーで表されるため、対応づけを行う。
        case stargazersCount = "stargazers_count"
        /// forksCount は JSON では "forks_count" というキーで表されるため、対応づけを行う。
        case forksCount = "forks_count"
        /// openIssuesCount は JSON では "open_issues_count" というキーで表されるため、対応づけを行う。
        case openIssuesCount = "open_issues_count"
        /// pushedAtString は JSON では "pushed_at" というキーで表されるため、対応づけを行う。
        case pushedAtString = "pushed_at"
    }
}
