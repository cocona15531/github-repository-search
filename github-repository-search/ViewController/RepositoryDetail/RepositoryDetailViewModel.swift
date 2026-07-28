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

    /// 表示用スター数。自分がスター済みなら全体数に自分の分（+1）を加える。
    private var displayStarCount: Int {
        gitHubRepository.stargazersCount + (isStarred ? 1 : 0)
    }

    /// 現在のスター状態に応じた表示数で uiModel を作り直す。
    private func updateUIModel() {
        uiModel = RepositoryDetailUIModelTranslator.translate(from: gitHubRepository, starCount: displayStarCount)
    }

    /// 画面表示時に呼ぶ。スター状態を取得してボタンと表示数に反映する。
    func didAppear() {
        Task {
            do {
                let starred = try await repository.isStarred(
                    owner: gitHubRepository.owner.login,
                    name: gitHubRepository.name
                )
                isStarred = starred
                updateUIModel()
            } catch {
                print(error.localizedDescription)
            }
            isStarButtonEnabled = true
        }
    }

    /// スターボタンがタップされたことを伝える。現在の状態に応じてスターを付与/解除する。
    func didTapStar() {
        guard isStarButtonEnabled else { return }
        isStarButtonEnabled = false
        Task {
            do {
                if isStarred {
                    try await repository.unstar(owner: gitHubRepository.owner.login, name: gitHubRepository.name)
                    isStarred = false
                } else {
                    try await repository.star(owner: gitHubRepository.owner.login, name: gitHubRepository.name)
                    isStarred = true
                }
                updateUIModel()
            } catch {
                print(error.localizedDescription)
            }
            isStarButtonEnabled = true
        }
    }
}
