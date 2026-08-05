# github-repository-search

GitHub の REST API を使って公開リポジトリを検索・閲覧できる iOS アプリです。入力した文字列でリポジトリを検索して一覧で表示し、選んだリポジトリの詳細を確認して、自分の GitHub アカウントでスターを付け外しできます。

<img width="4000" height="2240" alt="画面フロー図" src="https://github.com/user-attachments/assets/3cf1b4ed-15f6-437d-adb8-fd7609817cff" />



|レポジトリ一覧画面|レポジトリ詳細画面|
|---|---|
|<video src=https://github.com/user-attachments/assets/4806662b-80e7-4b59-bb66-13633b0e7a46>|<video src=https://github.com/user-attachments/assets/445555d8-6c68-4316-a8d1-29b373d7ca87>|

## 主な機能

- **リポジトリの検索**: 入力した文字列で GitHub の公開リポジトリを検索する
- **検索結果の一覧表示**: リポジトリ名・説明・スター数・オーナー（アイコンと名前）・主要言語を、言語ごとの色付きで表示する
- **リポジトリの詳細表示**: 説明・スター数・フォーク数・Issue 数・主要言語・最終更新日・トピックを表示する
- **スターの付与と解除**: 詳細画面から、自分のアカウントでスターを付けたり外したりする

## 技術スタック

| 項目 | 内容 |
| --- | --- |
| UI | UIKit（Storyboard / xib を使わずコードベースで実装、レイアウトは NSLayoutConstraint） |
| アーキテクチャ | MVVM + Repository |
| データフロー | Combine |
| 非同期処理 | async / await |
| 通信 | 自作の APIClient（URLSession。通信ライブラリは使用していない） |
| ライブラリ | SDWebImage（オーナーアイコンの非同期読み込みとキャッシュのみ） |

## セットアップ

動作環境は Xcode 26 / iOS 26.2 以上です。依存ライブラリ（SDWebImage）は Swift Package Manager で管理しているため、プロジェクトを開くと自動で解決されます。

スター系の API は認証が必要なため、GitHub の Personal Access Token を用意し、`github-repository-search/Secrets.swift` を作成してください。スコープは `public_repo`（または `repo`）です。

```swift
enum Secrets {
    /// star API の認証に使う GitHub の Personal Access Token。
    static let gitHubAccessToken = "＜自分の Personal Access Token＞"
}
```

このファイルはトークンを含むため `.gitignore` に登録しており、リポジトリにはコミットされません。トークンを設定しなくても検索・一覧・詳細表示は動作します（検索系 API は未認証で呼べるため）。スター状態の取得・付与・解除のみ失敗します。

## アーキテクチャ
<img width="4000" height="2240" alt="アプリアーキテクチャ統合図" src="https://github.com/user-attachments/assets/1925e3a8-d9f9-4bd0-bd1d-b6840ecc9406" />


今回の実践課題のアプリでは、MVVMアーキテクチャに加えて Repository を導入する構成で実装しました。

MVVM の利点は、ViewModel が持つ表示状態と View をバインドすることで、状態の変更に応じて UI が自動的に更新される点です。これにより更新漏れや表示の矛盾を防ぎやすく、画面の挙動を理解・テストしやすくなります。

これまでの開発では MVP に慣れていましたが、MVP は ViewController からロジックを分離しやすい一方で、画面が複雑になると Presenter が肥大化し、View と Presenter が相互に参照し合うことで結合度が高くなりがちです。この点を踏まえ今回は採用しませんでした。

ただし、MVVM をそのまま採用すると、ViewModel が画面の状態管理や表示ロジックに加えて API 通信・DB・キャッシュなどの処理まで抱え込み、肥大化してしまいます。そこで Repository を導入し、これらのデータ取得に関する処理を分離しました。その結果、ViewModel は画面状態と表示ロジックの管理に専念でき、テスト時には Repository をモックへ差し替えられる構成になっています。テスト自体は今回実装できていないため、今後の課題として取り組む予定です。

## 実装する上で意識したことの紹介

### 表示状態の一元化（ViewState）

ViewModel が現在の状態を1つだけ保持し、処理の進行に応じて状態を切り替える `ViewState` を用いて実装しました。View はその状態を見て表示を決めます。

```swift
/// 検索画面の状態。View はこれを購読して表示を切り替える。
enum ViewState: Equatable {
    /// 検索前。
    case initial
    /// 検索中。
    case loading
    /// 検索結果（0件の場合は空配列）。
    case content([RepositoryRowUIModel])
    /// 検索失敗時。String はエラーメッセージ。
    case error(String)
}
```

ViewModel は処理結果に応じて `ViewState` を変更し、View は個々の UI 部品をその都度操作するのではなく、状態ごとの表示処理をまとめて記述します。これにより、状態の変更が必ず表示に反映され、状態ごとの表示内容も1か所にまとまります。

```swift
switch state {
case .initial:
    self.loadingIndicator.stopAnimating()
    self.emptyStateStackView.isHidden = false
    self.applyItems([])
case .loading:
    self.loadingIndicator.startAnimating()
    self.emptyStateStackView.isHidden = true
    self.applyItems([])
case .content(let repositories):
    self.loadingIndicator.stopAnimating()
    self.emptyStateStackView.isHidden = true
    self.applyItems(repositories)
case .error(let message):
    self.loadingIndicator.stopAnimating()
    self.emptyStateStackView.isHidden = false
    self.applyItems([])
    self.showAlert(message: message)
}
```

### 画面遷移の責務分離（Router）

「どの画面に行くか」は画面の状態の一部と考え、ViewModel が `Router` として公開し、View は購読して画面遷移を行います。`Router` enum を見ればこの画面から行ける遷移先がすべて分かります。仮に今後遷移先を追加した場合、View 側の `switch` が非網羅になり、コンパイラが対応漏れを検出してくれます。

```swift
// ViewModel: 遷移先を決める
enum Router: Equatable {
    case detail(GitHubRepository)
}

func didSelectRepository(id: Int) {
    guard let repository = fetchedRepositories.first(where: { $0.id == id }) else { return }
    router = .detail(repository)
}
```

```swift
// View: 遷移を実行する
viewModel.$router
    .compactMap { $0 }
    .receive(on: DispatchQueue.main)
    .sink { [weak self] router in
        switch router {
        case .detail(let repository):
            let vc = RepositoryDetailViewControllerProvider.build(repository: repository)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    .store(in: &cancellables)
```

### データ取得の抽象化（Repository）

ViewModel が参照するのはプロトコルだけに留め、「データがどこから来たか」を知らないようにしました。その結果、テスト時にはプロトコルをモックに差し替えるだけで、ViewModel のテストは「状態遷移が正しいか」だけに集中できるようになります。

```swift
protocol RepositorySearchRepositoryProtocol {
    func searchRepositories(query: String) async throws(APIError) -> [GitHubRepository]
}

final class RepositorySearchRepository: RepositorySearchRepositoryProtocol {
    private let apiClient: any RepositorySearchServiceProtocol

    init(apiClient: any RepositorySearchServiceProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func searchRepositories(query: String) async throws(APIError) -> [GitHubRepository] {
        let response = try await apiClient.searchRepositories(SearchRepositoriesRequest(query: query))
        return response.repositories.map { RepositoryTranslator.translate(from: $0) }
    }
}
```

また、`APIClient` 全体に依存しないよう、使うメソッドだけを切り出したプロトコルに `APIClient` を extension で準拠させています。その結果、Repository のプロトコルと同様にモックへ差し替えるだけで、通信なしで Repository 単体をテストできます。

```swift
protocol RepositorySearchServiceProtocol {
    func searchRepositories(_ request: SearchRepositoriesRequest) async throws(APIError) -> SearchResponse
}

extension APIClient: RepositorySearchServiceProtocol {
    func searchRepositories(_ request: SearchRepositoriesRequest) async throws(APIError) -> SearchResponse {
        try await send(request)
    }
}
```

### モデル変換の集約（Translator）

モデルを **API レスポンス → DataModel → UIModel** の3段に分け、変換をそれぞれ Translator で行いました。その結果、整形や `nil` の穴埋めを View や ViewModel で行わず、View は整形済みの値をそのまま表示するだけでよくなります。

```swift
// API レスポンス → DataModel
enum RepositoryTranslator {
    static func translate(from response: RepositoryResponse) -> GitHubRepository { ... }
}

// DataModel → 一覧用の UIModel
enum RepositorySearchUIModelTranslator {
    static func translate(from repository: GitHubRepository) -> RepositoryRowUIModel {
        RepositoryRowUIModel(
            ...
            description: repository.description ?? "説明はありません",
            starCountText: "★ \(formattedStarCount(repository.stargazersCount))",
            ...
        )
    }

    /// スター数を、1万以上なら「X.X万」の形式に整形する。1万未満はそのままの数字にする。
    private static func formattedStarCount(_ count: Int) -> String {
        guard count >= 10_000 else { return "\(count)" }
        return String(format: "%.1f万", Double(count) / 10_000)
    }
}
```

### 遷移先の初期化と依存注入の集約（Provider）

詳細画面は ViewModel を `init` で受け取る形にし、初期化と依存注入を Provider にまとめました。呼び出し側は `build` だけを知れば済むので、ViewModel の依存が増えたり、ViewController の `init` が変わっても、直すのは `build` の中だけに留めることができます。

```swift
enum RepositoryDetailViewControllerProvider {
    @MainActor
    static func build(repository: GitHubRepository) -> RepositoryDetailViewController {
        let viewModel = RepositoryDetailViewModel(gitHubRepository: repository)
        return RepositoryDetailViewController(viewModel: viewModel)
    }
}
```

```swift
// View
let vc = RepositoryDetailViewControllerProvider.build(repository: repository)
```

### APIClient の汎用化（Generics + associatedtype）

エンドポイントごとにメソッドを増やさず、`RequestType` を渡すだけで呼べる汎用の `send` を1つ用意しました。

```swift
func send<Request: RequestType>(_ request: Request) async throws(APIError) -> Request.Response
```

`associatedtype` で Response を結びつけているため、**戻り値の型が Request 側で確定**します。

```swift
/// API のリクエストを表す型。返す Response 型を associatedtype で結びつけ、send の戻り値を型で確定させる。
protocol RequestType {
    associatedtype Response: ResponseType
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}
```

エンドポイントの追加時は `RequestType` に準拠したリクエストを用意するだけでよく、`APIClient` に手を入れずに汎用的に使えます。

```swift
struct SearchRepositoriesRequest: RequestType {
    typealias Response = SearchResponse
    let path = "/search/repositories"
    let method: HTTPMethod = .get
    let query: String
    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "q", value: query)]
    }
}
```

### 一覧画面の描画（CompositionalLayout + DiffableDataSource）

一覧は `UICollectionViewFlowLayout` と `UICollectionViewDataSource` の組み合わせではなく、CompositionalLayout と DiffableDataSource で実装しました。レイアウトには `UICollectionLayoutListConfiguration` によるリスト構成を使っています（詳細は「[UICollectionLayoutListConfiguration を用いて設定画面風に実装](#uicollectionlayoutlistconfiguration-を用いて設定画面風に実装)」に記載）。

データソース側は、`numberOfItemsInSection` や `cellForItemAt` を実装して「配列の状態を UICollectionView に説明する」のではなく、**表示したい状態そのもの**をスナップショットとして渡します。

```swift
/// 一覧に表示する行を差分更新する。
///
/// 新旧スナップショットの差分を DiffableDataSource が自動計算するため、変化した行だけがアニメーション付きで更新される。
private func applyItems(_ items: [RepositoryRowUIModel]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, RepositoryRowUIModel>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: true)
}
```

新旧の差分は DiffableDataSource が計算するため、`reloadData()` を呼ばずに変化した行だけが更新されます。これは ViewModel が `ViewState` として「今表示すべき状態」を公開している構成と相性が良く、View は受け取った状態を `applyItems` に渡すだけで済みます。配列の管理とデータソースの更新を別々に整合させる必要がありません。

また `CellRegistration` を使うことで、文字列の reuse identifier や `as!` による型変換なしに、セルとモデルの型を結びつけられます。

```swift
let cellRegistration = UICollectionView.CellRegistration<RepositoryCell, RepositoryRowUIModel> { cell, _, repository in
    cell.configure(with: repository)
}
```

## 新しく学んだこと

### UICollectionLayoutListConfiguration を用いて設定画面風に実装

リストの最初と最後のセルだけ角丸になる、iOS の設定アプリのようなリストを作りたかったため、`UICollectionLayoutListConfiguration` の `insetGrouped` を使いました。

```swift
/// 先頭・末尾の角丸やセルの区切り線が標準で提供される insetGrouped スタイルのリストレイアウトを組み立てる。
private func makeLayout() -> UICollectionViewCompositionalLayout {
    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    return UICollectionViewCompositionalLayout.list(using: configuration)
}
```

自分で実装するなら、セルの位置がリストの先頭・末尾・中間のどれかを判定し、`layer.maskedCorners` で角を出し分け、さらに区切り線を敷く処理が必要になります。`insetGrouped` を指定するだけで、角丸・左右のインセット・セル間の区切り線がすべて標準で提供されることを学びました。

### iOS 26 での検索バーの配置（preferredSearchBarPlacement）

`UISearchController` を `navigationItem.searchController` に載せる実装にしましたが、iOS 26 では検索バーが既定で**画面下部**に配置されます。課題のイメージ図は上部に検索バーがある形だったため、配置を明示的に指定しました。

```swift
navigationItem.searchController = searchController
// iOS 26 では検索バーの配置がデフォルトで画面下部になるため、
// OS間で見た目が変わらないようナビゲーションバーを画面上部に固定する。
if #available(iOS 26.0, *) {
    navigationItem.preferredSearchBarPlacement = .stacked
}
```

`.stacked` はナビゲーションタイトルの下に検索バーを積む配置です。同じコードでも OS のバージョンによって既定の見た目が変わることがあり、**新しい OS の既定値を確認して、意図した配置を明示する必要がある**ことを学びました。
