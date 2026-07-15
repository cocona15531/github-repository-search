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
            starCountText: "★ \(repository.stargazersCount)",
            ownerLogin: repository.ownerLogin,
            ownerAvatarURL: URL(string: repository.ownerAvatarURLString),
            languageText: repository.language
        )
    }
}
