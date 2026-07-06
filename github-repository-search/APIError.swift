//
//  APIError.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/29.
//

import Foundation

/// completion に渡す Error の種類を enum で定義する。
///
/// バックグラウンドスレッド（dataTask のクロージャ内）で生成して completion に渡すため、
/// メインアクター隔離を外す nonisolated を付与している。
nonisolated enum APIError: Error {
    /// URL の作成に失敗した場合のエラー。
    case invalidURL
    /// レスポンスとして解釈できなかった場合のエラー。
    case invalidResponse
    /// ステータスコードが 2xx 以外だった場合のエラー。
    case unacceptable(statusCode: Int)
    /// URLSession でのエラー。
    case urlSession(Error)
    /// デコードに失敗した場合のエラー。
    case decode(Error)
}
