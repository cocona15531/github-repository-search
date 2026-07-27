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
    /// 状態取得時点でスター済みだったか。stargazersCount はこの状態を含むため、表示数の基準に使う。
    private var isStarredAtFetch = false

    init(
        gitHubRepository: GitHubRepository,
        repository: any RepositoryDetailRepositoryProtocol = RepositoryDetailRepository()
    ) {
        self.gitHubRepository = gitHubRepository
        self.repository = repository
        self.uiModel = RepositoryDetailUIModelTranslator.translate(from: gitHubRepository, starCount: gitHubRepository.stargazersCount)
    }

    /// 取得時の全体数を基準に、取得時からのスター状態の変化分だけ増減した表示用スター数。
    private var displayStarCount: Int {
        gitHubRepository.stargazersCount - (isStarredAtFetch ? 1 : 0) + (isStarred ? 1 : 0)
    }

    /// 現在のスター状態に応じた表示数で uiModel を作り直す。
    private func updateUIModel() {
        uiModel = RepositoryDetailUIModelTranslator.translate(from: gitHubRepository, starCount: displayStarCount)
    }

    /// 画面表示時に呼ぶ。スター状態を取得してボタンと表示数に反映する。
    func onAppear() {
        Task {
            do {
                let starred = try await repository.isStarred(
                    owner: gitHubRepository.owner.login,
                    name: gitHubRepository.name
                )
                isStarredAtFetch = starred
                isStarred = starred
                updateUIModel()
            } catch {
                print(error.localizedDescription)
            }
            isStarButtonEnabled = true
        }
    }
}
