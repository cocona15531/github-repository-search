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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .systemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var ownerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, ownerNameLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private let repositoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private let languageDotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private lazy var languageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [languageDotView, languageLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()

    private let forkCountLabel = RepositoryDetailViewController.makeSubLabel()
    private let issueCountLabel = RepositoryDetailViewController.makeSubLabel()
    private let updatedAtLabel = RepositoryDetailViewController.makeSubLabel()
    private let topicsLabel = RepositoryDetailViewController.makeSubLabel()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            repositoryNameLabel,
            descriptionLabel,
            starCountLabel,
            languageStackView,
            forkCountLabel,
            issueCountLabel,
            updatedAtLabel,
            topicsLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ownerStackView, infoStackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 28
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(viewModel: RepositoryDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        setupViews()
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(cardView)
        cardView.addSubview(contentStackView)

        // 「画像にある項目」とそれ以外の間に少し余白を空けて区切りをつける。
        infoStackView.setCustomSpacing(20, after: issueCountLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // カードはスクロールする中身（contentLayoutGuide）に上下20で留める。
            // 幅は可視領域（frameLayoutGuide）に左右20で留める。
            cardView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            // 中身の下もカード下に留めることで、カードの高さが中身の高さに確定する。
            contentStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            contentStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28),

            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            languageDotView.widthAnchor.constraint(equalToConstant: 12),
            languageDotView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    /// fork数・issue数・更新日・topics 用の、グレー系サブラベルを生成する。
    private static func makeSubLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
}
