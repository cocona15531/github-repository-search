//
//  RepositoryCell.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import UIKit

/// 一覧の1件分のリポジトリ（名前・description・スター数）を表示するセル。
final class RepositoryCell: UICollectionViewCell {
    /// 主要言語ごとの色分け（GitHubの言語カラーに準拠した簡易マッピング）。
    private static let languageColors: [String: UIColor] = [
        "Swift": color(hex: 0xF05138),
        "Python": color(hex: 0x3572A5),
        "JavaScript": color(hex: 0xF1E05A),
        "TypeScript": color(hex: 0x3178C6),
        "C++": color(hex: 0xF34B7D),
        "C": color(hex: 0x555555),
        "Ruby": color(hex: 0x701516),
        "Go": color(hex: 0x00ADD8),
        "Java": color(hex: 0xB07219),
        "Jupyter Notebook": color(hex: 0xDA5B0B),
        "HTML": color(hex: 0xE34C26),
        "Shell": color(hex: 0x89E051),
        "Rust": color(hex: 0xDEA584),
        "Kotlin": color(hex: 0xA97BFF),
        "PHP": color(hex: 0x4F5D95),
    ]

    private static func color(hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }

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

    /// セルの再利用時に、切り替わり前の画像が一瞬表示されたり、
    /// 別の行の画像取得タスクが後から上書きしたりしないようキャンセルする。
    private var imageLoadTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        avatarImageView.image = nil
    }

    func configure(with repository: RepositoryRowUIModel) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        ownerNameLabel.text = repository.ownerLogin
        starCountLabel.text = repository.starCountText

        if let languageText = repository.languageText {
            languageLabel.text = languageText
            languageDotView.backgroundColor = Self.languageColors[languageText] ?? .systemGray3
            languageStackView.isHidden = false
        } else {
            languageStackView.isHidden = true
        }

        loadAvatarImage(from: repository.ownerAvatarURL)
    }

    /// avatars.githubusercontent.com はGitHub APIとは別ホストの画像バイナリなので、
    /// APIClient（GitHub APIのJSONエンドポイント専用）は使わず、URLSessionで直接取得する。
    private func loadAvatarImage(from url: URL?) {
        imageLoadTask?.cancel()
        avatarImageView.image = nil
        guard let url else { return }

        imageLoadTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled, let image = UIImage(data: data) else { return }
                avatarImageView.image = image
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func setupViews() {
        // ownerPillView/bottomRowStackViewを親スタックのarrangedSubviewsに直接入れると
        // .fillアライメントで幅いっぱいに引き伸ばされてしまうため、
        // 幅いっぱいの透明な行の中に、内容に応じた幅のまま左寄せする形にする。
        let ownerRow = UIView()
        ownerRow.translatesAutoresizingMaskIntoConstraints = false
        ownerRow.addSubview(ownerPillView)

        let bottomRow = UIView()
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.addSubview(bottomRowStackView)

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(ownerRow)
        contentView.addSubview(bottomRow)

        NSLayoutConstraint.activate([
            ownerPillView.topAnchor.constraint(equalTo: ownerRow.topAnchor),
            ownerPillView.bottomAnchor.constraint(equalTo: ownerRow.bottomAnchor),
            ownerPillView.leadingAnchor.constraint(equalTo: ownerRow.leadingAnchor),
            ownerPillView.trailingAnchor.constraint(lessThanOrEqualTo: ownerRow.trailingAnchor),

            bottomRowStackView.topAnchor.constraint(equalTo: bottomRow.topAnchor),
            bottomRowStackView.bottomAnchor.constraint(equalTo: bottomRow.bottomAnchor),
            bottomRowStackView.leadingAnchor.constraint(equalTo: bottomRow.leadingAnchor),
            bottomRowStackView.trailingAnchor.constraint(lessThanOrEqualTo: bottomRow.trailingAnchor),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            avatarImageView.widthAnchor.constraint(equalToConstant: 20),
            avatarImageView.heightAnchor.constraint(equalToConstant: 20),

            ownerRow.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            ownerRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ownerRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ownerRow.heightAnchor.constraint(equalToConstant: 28),

            bottomRow.topAnchor.constraint(equalTo: ownerRow.bottomAnchor, constant: 8),
            bottomRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            languageDotView.widthAnchor.constraint(equalToConstant: 8),
            languageDotView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
}

#Preview {
    let cell = RepositoryCell(frame: CGRect(x: 0, y: 0, width: 350, height: 80))
    cell.configure(with: RepositoryRowUIModel(
        id: 1,
        name: "swift",
        description: "The Swift Programming Language",
        starCountText: "★ 68000"
    ))
    return cell
}
