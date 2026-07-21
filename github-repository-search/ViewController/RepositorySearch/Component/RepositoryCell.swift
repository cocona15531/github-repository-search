//
//  RepositoryCell.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import SDWebImage
import SwiftUI
import UIKit

/// 一覧の1件分のリポジトリ（名前・description・スター数）を表示するセル。
final class RepositoryCell: UICollectionViewCell {
    // MARK: - View構造
    // contentView(W: superView.frame.W, H: 内容に応じて可変（AutoLayoutの自己サイズ計算）)
    //   ┣ nameLabel(W: contentView.frame.W - 32, H: textのsizeに合わせる)
    //   ┣ descriptionLabel(W: contentView.frame.W - 32, H: 最大2行分のtextのsizeに合わせる)
    //   ┣ ownerPillView(UIStackView) (W: 内容に応じた幅, H: 28)
    //   ┃     ┣ avatarImageView(W: 20, H: 20)
    //   ┃     ┗ ownerNameLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //   ┗ bottomRowStackView(UIStackView) (W: 内容に応じた幅, H: 内容に応じたH)
    //         ┣ starCountLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)
    //         ┗ languageStackView(UIStackView) (W: 内容に応じた幅, H: 内容に応じたH)
    //               ┣ languageDotView(W: 8, H: 8)
    //               ┗ languageLabel(W: textのsizeに合わせる, H: textのsizeに合わせる)

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .systemGray4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    /// オーナーのアイコン＋名前をまとめた、ピル型（角丸カプセル）のバッジ。
    private lazy var ownerPillView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, ownerNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 10)
        stackView.backgroundColor = .systemGray5
        stackView.layer.cornerRadius = 14
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemYellow
        return label
    }()

    private let languageDotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()

    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var languageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [languageDotView, languageLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()

    /// スター数と言語を横に並べる行。
    private lazy var bottomRowStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starCountLabel, languageStackView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    /// アバター画像の取得失敗時に表示するプレースホルダー。
    private static let avatarPlaceholderImage = UIImage(systemName: "person.crop.circle.fill")?
        .withTintColor(.white, renderingMode: .alwaysOriginal)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with repository: RepositoryRowUIModel) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        ownerNameLabel.text = repository.ownerLogin
        starCountLabel.text = repository.starCountText

        if let languageText = repository.languageText {
            languageLabel.text = languageText
            languageDotView.backgroundColor = LanguageColor.color(for: languageText)
            languageStackView.isHidden = false
        } else {
            languageStackView.isHidden = true
        }

        avatarImageView.sd_setImage(with: repository.ownerAvatarURL, placeholderImage: Self.avatarPlaceholderImage)
    }

    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(ownerPillView)
        contentView.addSubview(bottomRowStackView)

        // UICollectionLayoutListConfiguration によるセルの高さを推定する際、UIKitが入れる仮の高さと制約が衝突して警告が出るため、
        // 最下部の bottom 制約だけ優先度を下げる（実際の高さ計算には影響しない）。
        let bottomConstraint = bottomRowStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottomConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatarImageView.widthAnchor.constraint(equalToConstant: 20),
            avatarImageView.heightAnchor.constraint(equalToConstant: 20),

            ownerPillView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            ownerPillView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ownerPillView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            ownerPillView.heightAnchor.constraint(equalToConstant: 28),

            bottomRowStackView.topAnchor.constraint(equalTo: ownerPillView.bottomAnchor, constant: 8),
            bottomRowStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomRowStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            bottomConstraint,

            languageDotView.widthAnchor.constraint(equalToConstant: 8),
            languageDotView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
}

struct RepositoryCellPreview: PreviewProvider {
    struct Wrapper: UIViewRepresentable {
        let repository: RepositoryRowUIModel

        func makeUIView(context: Context) -> some UIView {
            let cell = RepositoryCell(frame: CGRect(x: 0, y: 0, width: 350, height: 0))
            cell.configure(with: repository)
            return cell.contentView
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }

    static var previews: some View {
        Group {
            Wrapper(repository: RepositoryRowUIModel(
                id: 1,
                name: "swift",
                description: "The Swift Programming Language",
                starCountText: "6.2万",
                ownerLogin: "apple",
                ownerAvatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4"),
                languageText: "C++"
            ))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("言語・アバターあり")

            Wrapper(repository: RepositoryRowUIModel(
                id: 2,
                name: "sample-repo",
                description: "説明はありません",
                starCountText: "10",
                ownerLogin: "someone",
                ownerAvatarURL: nil,
                languageText: nil
            ))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("言語・アバターなし")

            Wrapper(repository: RepositoryRowUIModel(
                id: 3,
                name: "long-description-repo",
                description: "説明文がとても長く、2行を超えるとどのように省略されるかを確認するためのプレビュー用テキストです。3行目以降は表示されず末尾が...になることを期待しています。",
                starCountText: "1.2万",
                ownerLogin: "example",
                ownerAvatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4"),
                languageText: "Swift"
            ))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("descriptionが長い場合")

            Wrapper(repository: RepositoryRowUIModel(
                id: 4,
                name: "long-owner-name-repo",
                description: "オーナー名が長い場合にピルの表示が崩れないかを確認するためのプレビュー",
                starCountText: "42",
                ownerLogin: "a-very-long-organization-name-that-does-not-fit-in-one-line",
                ownerAvatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4"),
                languageText: "Python"
            ))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("オーナー名が長い場合")

            Wrapper(repository: RepositoryRowUIModel(
                id: 5,
                name: "broken-avatar-repo",
                description: "アバター画像の取得に失敗した場合にプレースホルダーが表示されることを確認するためのプレビュー",
                starCountText: "3",
                ownerLogin: "unreachable",
                ownerAvatarURL: URL(string: "https://invalid.example.invalid/avatar.png"),
                languageText: "Ruby"
            ))
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("アバター画像の取得に失敗した場合")
        }
    }
}
