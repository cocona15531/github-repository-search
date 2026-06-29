//
//  APIClient.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/06/25.
//

import Foundation

final class APIClient {

    /// GitHub のリポジトリ検索 API を呼び出す。
    ///
    /// completion は API の呼び出しが完了したときに呼ばれる。
    /// 成功時には SearchResponse が渡され、失敗時には Error が渡される。
    func searchRepositories(completion: @escaping (Result<SearchResponse, Error>) -> Void) {

        // URLRequest を取り出す。
        guard let request = makeRequest() else {
            // URLRequest の作成に失敗した場合はエラーを出力して終了する。
            print("URLRequest の作成に失敗しました。")
            return
        }

        // URLSession を使用して API を呼び出す。
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // エラーが発生した場合はエラーを出力して終了する。
            if let error = error {
                print("API呼び出し中にエラーが発生しました: \(error)")
                return
            }

            // レスポンスのステータスコードを確認する。
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTPステータスコード: \(httpResponse.statusCode)")
            }

            // 取得したデータを文字列として出力する。
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("取得したデータ: \(jsonString)")
            }

            guard let data = data else {
                // データが nil の場合はエラーを出力して終了する。
                print("取得したデータが nil です。")
                return
            }
        }
        task.resume()
    }

    /// URLRequest を作成する。
    private func makeRequest() -> URLRequest? {

        // 1. URLComponents でベースURLを定義する。
        var components = URLComponents(string: "https://api.github.com/search/repositories")

        // 2. クエリパラメータを追加する。
        components?.queryItems = [
            URLQueryItem(name: "q", value: "Swift"),
        ]

        // 3. URLComponents から URL を取得する。
        // 正常に URL が作成できなかった場合は nil を返す。
        guard let url = components?.url else {
            return nil
        }

        // 4. URLRequest を作成する。
        var request = URLRequest(url: url)
        // GET メソッドを使用するので、httpMethod を "GET" に設定する。
        request.httpMethod = "GET"

        // 5. application/vnd.github+json を Accept ヘッダーに設定することが公式ドキュメントで推奨されているので、設定する。
        // https://docs.github.com/ja/rest/search/search?apiVersion=2026-03-10#search-repositories
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        // 設定は推奨されていないが、コードサンプルでは X-GitHub-Api-Version ヘッダーを設定しており、
        // APIのバージョンを指定することで将来的な互換性の問題を回避できる可能性があるため、設定しておく。
        // ここではコードサンプルに記載されている日付を使用する。
        request.setValue("2026-03-10", forHTTPHeaderField: "X-GitHub-Api-Version")

        // 6. 作成した URLRequest を返す。
        return request
    }
}
