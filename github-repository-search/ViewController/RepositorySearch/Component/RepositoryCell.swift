//
//  RepositoryCell.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import UIKit

/// 一覧の1件分のリポジトリ（名前・description・スター数）を表示するセル。
final class RepositoryCell: UICollectionViewCell {

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
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
        ])
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with repository: RepositoryRowUIModel) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        starCountLabel.text = repository.starCountText
    }

    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, starCountLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
