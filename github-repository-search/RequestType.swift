//
//  RequestType.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/03.
//

import Foundation

/// API のリクエストを表す型。ResponseType と対になり、Generics の send の型制約として使う。
protocol RequestType {
    static var path: String { get }
    static var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

/// クエリを持たないリクエストは queryItems を書かなくてよい（自動で空配列を加える）。
extension RequestType {
    var queryItems: [URLQueryItem] { [] }
}

extension URLRequest {
    /// RequestType と baseURL から URLRequest を組み立てる。
    init?<Request>(_ request: Request, baseURL: URL) where Request: RequestType {
        let url = baseURL.appending(path: Request.path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }
        guard let urlWithQuery = components.url else { return nil }
        self.init(url: urlWithQuery)
        self.httpMethod = Request.method.rawValue
    }
}
