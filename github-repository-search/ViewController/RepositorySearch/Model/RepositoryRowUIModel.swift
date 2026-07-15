//
//  RepositoryRowUIModel.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/14.
//

import Foundation

/// 1セル分をそのまま画面に表示できる形になったデータモーデル。
nonisolated struct RepositoryRowUIModel: Hashable, Sendable {
    let id: Int
    let name: String
    let description: String
    let starCountText: String
}
