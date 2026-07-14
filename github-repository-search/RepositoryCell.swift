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
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemYellow
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
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
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
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
