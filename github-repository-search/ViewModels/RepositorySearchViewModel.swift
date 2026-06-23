//
//  RepositorySearchViewModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/19.
//

import Combine
import Foundation

@MainActor
final class RepositorySearchViewModel {
    /// GETボタンの状態。ここでは色などの見た目は持たず、状態そのものだけを表す。
    enum ButtonState {
        case off
        case on
    }

    /// ViewからViewModelへのイベント通知口。
    ///
    /// PassthroughSubjectは値を保持せず、送られた瞬間だけ流す。
    /// privateにして外部から購読できないようにし、入口はdidTapGetButton()に限定する。
    private let getButtonTapped = PassthroughSubject<Void, Never>()

    /// ボタンの状態。View側はこれを購読して背景色を更新する。
    ///
    /// @Publishedを付けると「$buttonState」という変化通知用のPublisherが自動で作られ、
    /// 値が変わるたびに$buttonState経由で流す。購読開始時に現在値も即座に流れる。
    /// private(set)で、状態を変えられるのはViewModel内部だけに限定する。
    @Published private(set) var buttonState: ButtonState = .off

    /// 購読（subscription）を保持しておくためのプロパティ。
    ///
    /// これに保持しないと購読がすぐに解放され、イベントを受け取れなくなる。
    private var cancellables = Set<AnyCancellable>()

    /// ViewModelの初期化。
    init() {
        // ここでイベントの購読を行う。
        getButtonTapped
            .sink { [weak self] in
                guard let self else { return }
                // ボタンのタップイベントが来るたびにボタンの状態をオン・オフで反転させる。
                self.buttonState = (self.buttonState == .off) ? .on : .off
            }
            .store(in: &cancellables)
    }

    /// GETボタンがタップされたことをこのViewModelに伝える。
    func didTapGetButton() {
        getButtonTapped.send()
    }
}
