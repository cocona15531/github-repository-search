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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupButton()
    }

    private func setupButton() {
        view.addSubview(getButton)
        NSLayoutConstraint.activate([
            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            getButton.widthAnchor.constraint(equalToConstant: 80),
            getButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}

