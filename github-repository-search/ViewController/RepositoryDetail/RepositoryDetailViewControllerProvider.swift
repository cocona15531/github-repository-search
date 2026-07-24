//
//  RepositoryDetailViewControllerProvider.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/24.
//

import Foundation

/// リポジトリ詳細画面（RepositoryDetailViewController）の生成を担う。
///
/// ViewModel の生成と依存の注入を build に集約し、呼び出し側は build の入口だけを知ればよいようにする。
enum RepositoryDetailViewControllerProvider {
    @MainActor
    static func build(repository: GitHubRepository) -> RepositoryDetailViewController {
        let viewModel = RepositoryDetailViewModel(gitHubRepository: repository)
        return RepositoryDetailViewController(viewModel: viewModel)
    }
}
