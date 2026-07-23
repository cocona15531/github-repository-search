//
//  RepositoryDetailUIModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/23.
//

import Foundation

/// リポジトリ詳細画面をそのまま表示できる形に整えたデータモデル。
///
/// nonisolated を付けているのは、プロジェクト全体がデフォルトで MainActor 分離される設定になっており、
/// Combine で View へ渡す際に Sendable として扱えるようにするため。
nonisolated struct RepositoryDetailUIModel: Hashable, Sendable {
    /// オーナー名（例: apple）。
    let ownerName: String
    /// オーナーのアイコン画像 URL。
    let ownerAvatarURL: URL?
    /// リポジトリ名（例: swift）。
    let repositoryName: String
    /// リポジトリの説明。未設定の場合は代替文言が入る。
    let description: String
    /// スター数の表示文字列（例: ★ 56000）。
    let starCountText: String
    /// フォーク数の表示文字列（例: フォーク数：1234）。
    let forkCountText: String
    /// オープンな Issue 数の表示文字列（例: issue数：56）。
    let issueCountText: String
    /// 主要言語。設定されていない場合は nil。
    let languageText: String?
    /// 最終更新日の表示文字列（例: 更新日：2026/07/15）。取得できない場合は空文字。
    let updatedAtText: String
    /// トピックの表示文字列（例: トピック：swift, ios）。無い場合は空文字。
    let topicsText: String
}
