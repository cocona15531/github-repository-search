//
//  RepositorySearchViewModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/19.
//

import Combine
import Foundation

final class RepositorySearchViewModel {
    // ViewからViewModelへのイベント通知口。
    // PassthroughSubjectは値を保持せず、送られた瞬間だけ流す。
    let getButtonTapped = PassthroughSubject<Void, Never>()

    // 購読（subscription）を保持するための必須セット。
    private var cancellables = Set<AnyCancellable>()

    init() {
        // ここで購読。イベントが流れてきたときの処理を定義する。
        getButtonTapped
            .sink { _ in
                // ボタンがタップされたときの処理をここに書く
                print("GET button tapped")
            }
            .store(in: &cancellables)
    }
}
