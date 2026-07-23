//
//  RepositoryDetailViewModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/23.
//

import Combine
import Foundation

@MainActor
final class RepositoryDetailViewModel {
    /// 詳細画面の表示内容。View はこれを購読して表示に使う。
    @Published private(set) var uiModel: RepositoryDetailUIModel

    init(gitHubRepository: GitHubRepository) {
        self.uiModel = RepositoryDetailUIModelTranslator.translate(from: gitHubRepository)
    }
}
