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
    /// 自分がこのリポジトリをスターしているか。View はこれを購読してボタンの見た目に使う。
    @Published private(set) var isStarred = false
    /// スターボタンの活性状態。状態取得が完了するまでは無効にして誤操作を防ぐ。
    @Published private(set) var isStarButtonEnabled = false

    private let gitHubRepository: GitHubRepository
    private let repository: any RepositoryDetailRepositoryProtocol

    init(
        gitHubRepository: GitHubRepository,
        repository: any RepositoryDetailRepositoryProtocol = RepositoryDetailRepository()
    ) {
        self.gitHubRepository = gitHubRepository
        self.repository = repository
        self.uiModel = RepositoryDetailUIModelTranslator.translate(from: gitHubRepository, starCount: gitHubRepository.stargazersCount)
    }
}
