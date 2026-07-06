//
//  ViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/05.
//

import Combine
import UIKit

final class ViewController: UIViewController {
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
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$buttonState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.getButton.backgroundColor = state == .off ? .systemBlue : .systemGreen
            }
            .store(in: &cancellables)
    }

    private func setupButton() {
        view.addSubview(getButton)
        NSLayoutConstraint.activate([
            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            getButton.widthAnchor.constraint(equalToConstant: 80),
            getButton.heightAnchor.constraint(equalToConstant: 80),
        ])
        getButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.didTapGetButton()
        }, for: .touchUpInside)
    }
}

