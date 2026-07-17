//
//  RepositorySearchUIModelTranslator.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// GitHubRepository を RepositoryRowUIModel に変換する。
enum RepositorySearchUIModelTranslator {
    static func translate(from repository: GitHubRepository) -> RepositoryRowUIModel {
        RepositoryRowUIModel(
            id: repository.id,
            name: repository.name,
            description: repository.description ?? "説明はありません",
            starCountText: "★ \(formattedStarCount(repository.stargazersCount))",
            ownerLogin: repository.owner.login,
            ownerAvatarURL: URL(string: repository.owner.avatarURLString),
            languageText: repository.language
        )
    }

    /// スター数を、1万以上なら「X.X万」の形式に整形する。1万未満はそのままの数字にする。
    private static func formattedStarCount(_ count: Int) -> String {
        guard count >= 10_000 else { return "\(count)" }
        return String(format: "%.1f万", Double(count) / 10_000)
    }
}
