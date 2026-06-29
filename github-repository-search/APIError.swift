//
//  APIError.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/29.
//

import Foundation

/// completion に渡す Error の種類を enum で定義する。
enum APIError: Error {
    /// データが取得できなかった場合のエラー。
    case noData
    /// URL の作成に失敗した場合のエラー。
    case invalidURL
}
