//
//  RepositoryTranslator.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// RepositoryResponse（API レスポンス）を GitHubRepository（DataModel）に変換する。
enum RepositoryTranslator {
    static func translate(from response: RepositoryResponse) -> GitHubRepository {
        GitHubRepository(
            id: response.id,
            name: response.name,
            description: response.description,
            stargazersCount: response.stargazersCount,
            language: response.language,
            owner: GitHubRepository.Owner(
                login: response.owner.login,
                avatarURLString: response.owner.avatarURLString
            )
        )
    }
}
