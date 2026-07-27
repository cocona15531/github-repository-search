//
//  RepositoryDetailViewController.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/23.
//

import Combine
import SDWebImage
import UIKit

/// リポジトリの詳細情報をカード型レイアウトで表示する画面。
///
/// アバターとオーナー名を上部中央に表示し、その下に各種情報（説明・スター/Fork/Issue 数・言語・更新日・topics）を左寄せで並べる。
final class RepositoryDetailViewController: UIViewController {
    private let viewModel: RepositoryDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - View構造
    // view(W: 画面幅, H: 画面高)
    //   ┗ scrollView(W: view.frame.W, H: safeArea上端〜view下端)
    //       ┗ cardView(W: 可視領域の左右40を除いた幅, H: 内容に応じて可変)
    //           ┗ contentStackView(UIStackView) (W: cardView.W - 40, H: 内容に応じて可変)
    //               ┣ ownerStackView(UIStackView) (W: contentStackView.W, H: 内容に応じたH)
    //               ┃     ┣ avatarImageView(W: 80, H: 80)
    //               ┃     ┗ ownerNameLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //               ┗ infoStackView(UIStackView) (W: contentStackView.W, H: 内容に応じたH)
    //                     ┣ repositoryNameLabel(W: 最大 infoStackView.W, H: 折り返したtextのsizeに合わせる)
    //                     ┣ descriptionLabel(W: 最大 infoStackView.W, H: 折り返したtextのsizeに合わせる)
    //                     ┣ starStackView(UIStackView) (W: 内容に応じた幅, H: 内容に応じたH)
    //                     ┃     ┣ starButton(W: アイコンサイズ, H: アイコンサイズ)
    //                     ┃     ┗ starCountLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //                     ┣ languageStackView(UIStackView) (W: 内容に応じた幅, H: 内容に応じたH)
    //                     ┃     ┣ languageDotView(W: 12, H: 12)
    //                     ┃     ┗ languageLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //                     ┗ subInfoStackView(UIStackView) (W: 内容に応じた幅, H: 内容に応じたH)
    //                           ┣ forkCountLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //                           ┣ issueCountLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //                           ┣ updatedAtLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //                           ┗ topicsLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)

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
        imageView.backgroundColor = .white
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

    private let starButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        button.tintColor = .black
        return button
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starButton, starCountLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
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
            starStackView,
            languageStackView,
            subInfoStackView
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()

    private lazy var subInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
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
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(viewModel: RepositoryDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        setupViews()
        bindViewModel()
        viewModel.didAppear()
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(cardView)
        cardView.addSubview(contentStackView)

        infoStackView.setCustomSpacing(16, after: languageStackView)

        starButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.didTapStar()
        }, for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 40),
            cardView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -40),
            cardView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            contentStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 100),
            contentStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -100),

            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            languageDotView.widthAnchor.constraint(equalToConstant: 12),
            languageDotView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    /// ViewModel の表示内容を購読し、更新のたびに setupUI で UI を反映する。
    private func bindViewModel() {
        viewModel.$uiModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uiModel in
                self?.setupUI(uiModel)
            }
            .store(in: &cancellables)

        viewModel.$isStarred
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isStarred in
                self?.updateStarButton(isStarred: isStarred)
            }
            .store(in: &cancellables)

        viewModel.$isStarButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.starButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
    }

    /// スター状態に応じて、ボタンの星アイコン（未スター=star／スター済み=star.fill）を切り替える。
    private func updateStarButton(isStarred: Bool) {
        let imageName = isStarred ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
    }

    /// uiModel の内容を各 UI コンポーネントへ反映する。
    private func setupUI(_ uiModel: RepositoryDetailUIModel) {
        avatarImageView.image = nil
        avatarImageView.sd_setImage(with: uiModel.ownerAvatarURL, completed: { [weak self] _, error, _, _ in
            if error != nil {
                self?.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
            }
        })
        ownerNameLabel.text = uiModel.ownerName
        repositoryNameLabel.text = uiModel.repositoryName
        descriptionLabel.text = uiModel.description
        starCountLabel.text = uiModel.starCountText
        forkCountLabel.text = uiModel.forkCountText
        issueCountLabel.text = uiModel.issueCountText

        if let languageText = uiModel.languageText {
            languageLabel.text = languageText
            languageDotView.backgroundColor = LanguageColor.color(for: languageText)
            languageStackView.isHidden = false
        } else {
            languageStackView.isHidden = true
        }

        updatedAtLabel.text = uiModel.updatedAtText
        updatedAtLabel.isHidden = uiModel.updatedAtText.isEmpty

        topicsLabel.text = uiModel.topicsText
        topicsLabel.isHidden = uiModel.topicsText.isEmpty
    }

    /// fork数・issue数・更新日・topics 用の、少し小さめ（14pt）のサブ情報ラベルを生成する。
    private static func makeSubLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }
}
