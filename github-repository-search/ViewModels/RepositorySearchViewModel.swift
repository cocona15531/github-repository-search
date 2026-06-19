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

    init() {
    }
}
