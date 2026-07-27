//
//  RepositoryDetailUIModelTranslator.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/23.
//

import Foundation

/// GitHubRepository（DataModel）を RepositoryDetailUIModel（表示用モデル）に変換する。
///
/// 数値・日付・トピックの整形や nil 処理をこのファイルに集約し、View や ViewModel では行わせない。
enum RepositoryDetailUIModelTranslator {
    static func translate(from repository: GitHubRepository) -> RepositoryDetailUIModel {
        RepositoryDetailUIModel(
            ownerName: repository.owner.login,
            ownerAvatarURL: URL(string: repository.owner.avatarURLString),
            repositoryName: repository.name,
            description: repository.description ?? "説明はありません",
            starCountText: formattedCount(repository.stargazersCount),
            languageText: repository.language,
            forkCountText: "フォーク数：\(formattedCount(repository.forksCount))",
            issueCountText: "issue数：\(formattedCount(repository.openIssuesCount))",
            updatedAtText: formattedUpdatedAt(repository.updatedAtString),
            topicsText: formattedTopics(repository.topics)
        )
    }

    /// 数値を 3 桁区切り（例: 56,000）に整形する。
    private static func formattedCount(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }

    /// ISO8601 の updated_at を「更新日：yyyy/MM/dd」に整形する。無い・解釈できない場合は空文字にする。
    private static func formattedUpdatedAt(_ isoString: String?) -> String {
        guard let isoString, let date = ISO8601DateFormatter().date(from: isoString) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        return "更新日：\(formatter.string(from: date))"
    }

    /// トピック一覧を「トピック：a, b, c」に整形する。空の場合は空文字にする。
    private static func formattedTopics(_ topics: [String]) -> String {
        guard !topics.isEmpty else { return "" }
        return "トピック：\(topics.joined(separator: ", "))"
    }
}
