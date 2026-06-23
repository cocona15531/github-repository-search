//
//  ViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/05.
//

import Combine
import UIKit

class ViewController: UIViewController {

    // ViewはViewModelを保持する。
    private let viewModel = RepositorySearchViewModel()

    /// 購読を保持しておくためのプロパティ。これがないと購読がすぐ解放され値を受け取れない。
    private var cancellables = Set<AnyCancellable>()

    private let getButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GET", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// Viewが表示されるときに呼ばれる。
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        // ここでButtonのセットアップとViewModelとのバインディングを行う。
        setupButton()
        bindViewModel()
    }

    /// ViewModelの出力を購読し、状態の変化に応じてViewを更新する。
    private func bindViewModel() {
        viewModel.$buttonState
            // UIの更新はメインスレッドで行う。
            .receive(on: DispatchQueue.main)
            // sinkで購読を開始し、値が流れてくるたびにクロージャを実行する。
            .sink { [weak self] state in
                // 状態に応じて背景色を切り替える。
                switch state {
                case .off:
                    self?.getButton.backgroundColor = .systemBlue
                case .on:
                    self?.getButton.backgroundColor = .systemGreen
                }
            }
            // storeで購読をcancellablesに保持する。これがないと購読がすぐ解放され値を受け取れない。
            .store(in: &cancellables)
    }

    /// ボタンをViewに配置。
    private func setupButton() {
        view.addSubview(getButton)
        NSLayoutConstraint.activate([
            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            getButton.widthAnchor.constraint(equalToConstant: 80),
            getButton.heightAnchor.constraint(equalToConstant: 80),
        ])
        // ボタンタップ時にViewModelへイベントを送る。
        getButton.addTarget(self, action: #selector(didTapGetButton), for: .touchUpInside)
    }

    @objc private func didTapGetButton() {
        // タップされたことをViewModelに伝える。
        viewModel.didTapGetButton()
    }
}

