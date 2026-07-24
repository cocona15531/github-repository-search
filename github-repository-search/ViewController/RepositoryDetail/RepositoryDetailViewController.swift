//
//  RepositoryDetailViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/23.
//

import UIKit

/// リポジトリの詳細情報を表示する画面。
///
/// レイアウトと表示内容の反映は後続のコミットで追加する。
final class RepositoryDetailViewController: UIViewController {
    private let viewModel: RepositoryDetailViewModel

    init(viewModel: RepositoryDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
