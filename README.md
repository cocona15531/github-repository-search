# github-repository-search

GitHub の REST API を使って公開リポジトリを検索・閲覧できる iOS アプリです。入力した文字列でリポジトリを検索して一覧で表示し、選んだリポジトリの詳細を確認して、自分の GitHub アカウントでスターを付け外しできます。

<img width="4000" height="2240" alt="画面フロー図" src="https://github.com/user-attachments/assets/e900aa51-fee5-4e4d-8d00-ebed8833475b" />

<br>

|レポジトリ一覧画面|レポジトリ詳細画面|
|---|---|
|<video src=https://github.com/user-attachments/assets/4806662b-80e7-4b59-bb66-13633b0e7a46>|<video src=https://github.com/user-attachments/assets/445555d8-6c68-4316-a8d1-29b373d7ca87>|

## 目次

- [技術スタック](#技術スタック)
- [セットアップ](#セットアップ)
- [アーキテクチャ](#アーキテクチャ)
  - [MVVM + Repository の構成](#mvvm--repository-の構成)
  - [MVP で書いた場合との比較](#mvp-で書いた場合との比較)
    - [MVVM のメリット（MVP と比べて）](#mvvm-のメリットmvp-と比べて)
    - [MVVM のデメリット（MVP と比べて）](#mvvm-のデメリットmvp-と比べて)
- [実装する上で意識したことの紹介](#実装する上で意識したことの紹介)
  - [ライフサイクル](#ライフサイクル)
  - [Combine](#combine)
  - [参照](#参照)
  - [エラー設計](#エラー設計)
  - [疎結合](#疎結合)
  - [抽象化](#抽象化)
  - [凝集度](#凝集度)
  - [DRY 原則](#dry-原則)
  - [APIClient](#apiclient)
  - [ViewState](#viewstate)
  - [Router](#router)
  - [Repository](#repository)
  - [Translator](#translator)
  - [Provider](#provider)
- [新しく学んだこと](#新しく学んだこと)
  - [UICollectionLayoutListConfiguration を用いて設定画面風に実装](#uicollectionlayoutlistconfiguration-を用いて設定画面風に実装)
  - [iOS 26 での検索バーの配置（preferredSearchBarPlacement）](#ios-26-での検索バーの配置preferredsearchbarplacement)
  - [AI が出力したコードのセルフレビュー](#ai-が出力したコードのセルフレビュー)
- [感想・振り返り](#感想振り返り)

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

今回の実践課題のアプリでは、MVVM アーキテクチャに加えて Repository を導入する構成で実装しました。

### MVVM + Repository の構成

MVVM は View / ViewModel / Model に分け、ViewModel が画面の表示状態を持ち、View はそれを購読して描画する構成です。ViewModel は View を参照しないため、依存は View → ViewModel の一方向になります。

ただし MVVM をそのまま採用すると、ViewModel が画面の状態管理や表示ロジックに加えて API 通信やキャッシュの処理まで抱え込み、肥大化してしまいます。そこで Repository を導入し、データ取得に関する処理を分離しました。その結果、ViewModel は画面状態と表示ロジックの管理に専念でき、テスト時には Repository をモックへ差し替えられる構成になっています。テスト自体は今回実装できていないため、今後の課題として取り組む予定です。

### MVP で書いた場合との比較

これまでの開発では MVP を採用したプロジェクトが中心で、MVP での書き方に慣れていました。その書き方では、Presenter が用途ごとの Subject を公開し、View がそれぞれを購読する形にしていました。Presenter が View への参照を持たない点は MVVM と同じで、違うのは公開する単位が「用途ごと」か「画面の状態ひとつ」かです。今回の検索処理を MVP の書き方に置き換えると、次のようになります。

```swift
// MVP で書いた場合
@MainActor protocol RepositorySearchPresenterProtocol {
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var repositories: CurrentValueSubject<[RepositoryRowUIModel], Never> { get }
    var alertMessage: CurrentValueSubject<String?, Never> { get }
    var onGoToDetail: PassthroughSubject<GitHubRepository, Never> { get }

    func didSubmitSearch(query: String)
    func didSelectRepository(id: Int)
}

final class RepositorySearchPresenter: RepositorySearchPresenterProtocol {
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let repositories = CurrentValueSubject<[RepositoryRowUIModel], Never>([])
    let alertMessage = CurrentValueSubject<String?, Never>(nil)
    let onGoToDetail = PassthroughSubject<GitHubRepository, Never>()

    func didSubmitSearch(query: String) {
        isLoading.send(true)
        Task {
            do {
                fetchedRepositories = try await repository.searchRepositories(query: query)
                repositories.send(fetchedRepositories.map { RepositorySearchUIModelTranslator.translate(from: $0) })
            } catch {
                alertMessage.send(error.localizedDescription)
            }
            isLoading.send(false)
        }
    }
}
```

View 側は Subject ごとに購読を張り、表示の組み合わせを自分で判断します。

```swift
// MVP: View が購読を複数張り、組み合わせも View 側で決める
presenter.isLoading
    .sink { [weak self] isLoading in
        isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
    }
    .store(in: &cancellables)

presenter.repositories
    .sink { [weak self] repositories in
        self?.applyItems(repositories)
        self?.emptyStateStackView.isHidden = !repositories.isEmpty
    }
    .store(in: &cancellables)
```

今回の MVVM では、これを状態1つにまとめました。

```swift
// MVVM: 状態を1つ公開する
enum ViewState: Equatable {
    case initial
    case loading
    case content([RepositoryRowUIModel])
    case error(String)
}

private func search(query: String) async {
    state = .loading
    do {
        fetchedRepositories = try await repository.searchRepositories(query: query)
        state = .content(fetchedRepositories.map { RepositorySearchUIModelTranslator.translate(from: $0) })
    } catch {
        state = .error(error.localizedDescription)
    }
}
```

View 側は購読1本で、状態ごとに表示を決めます。

```swift
// MVVM: View は購読1本で、状態ごとに描画する
viewModel.$state
    .receive(on: DispatchQueue.main)
    .sink { [weak self] state in
        guard let self else { return }
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
            ...
        case .error(let message):
            ...
        }
    }
    .store(in: &cancellables)
```

#### MVVM のメリット（MVP と比べて）

MVP では自分で気をつけていた部分が構造で担保されるようになり、記述量も減りました。

1つは、表示の組み合わせを ViewModel が決められる点です。MVP では「ローディング中は空表示を隠す」「一覧が空なら空表示を出す」といった判断が View に散りますが、状態を1つにまとめたことで、View は状態ごとに描画するだけになりました。

また、区別したい状態を型で分けられるようになりました。MVP では `repositories` が空配列のときに「未検索」なのか「検索結果が0件」なのかを判別できず、フラグを追加することになります。`.initial` と `.content([])` を別のケースにしたことで、この2つを型として表現できました。

さらに、宣言と購読のコード量を削減できました。MVP では出力の種類ごとに Subject を宣言し、View 側にも `receive(on:)` / `sink` / `store(in:)` の購読を1本ずつ書く必要がありました。MVVM では状態1つの宣言と購読1本に収まるため、画面の出力が増えてもこの部分は増えません。

#### MVVM のデメリット（MVP と比べて）

一方で、MVP のほうが書きやすいと感じた点もあります。

まず、状態の一部だけを更新できません。詳細画面でスター数だけ変えたい場合も、`updateUIModel()` で `uiModel` を作り直しています。MVP なら該当の Subject に `send` するだけで済んでいた部分です。

また、View 側の分岐の記述量は増えます。状態のケース数 × 表示要素の数だけ設定を書くことになり、ケース毎に値の設定漏れが起きやすくなります。

そして、表示状態が少ない画面ではオーバースペックになります。取りうる状態が2つ程度なら、Subject を1つ置くほうが手軽だと感じます。


## 実装する上で意識したことの紹介

### ライフサイクル

Storyboard を使わないため、画面の生成は `SceneDelegate` で組み立てています。詳細画面は `init(viewModel:)` のみを公開し、`required init?(coder:)` は `fatalError()` にして、コードベース以外からの生成を防ぎました。

購読の開始は `viewDidLoad` で1回だけ行いました。`viewWillAppear` のように複数回呼ばれるタイミングで購読すると二重購読になるためです。購読は `cancellables` にまとめて保持しているので、ViewController の解放と同時に止まります。

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    setupViews()
    bindViewModel()
    viewModel.didAppear()
}
```

詳細画面のスター状態の取得は「画面が表示されたこと」を起点にしたかったため、View から `didAppear()` を呼ぶ形にしました。取得が終わるまでは `isStarButtonEnabled` を `false` にして、状態が確定する前のタップを防いでいます。

```swift
/// 画面表示時に呼ぶ。スター状態を取得してボタンと表示数に反映する。
func didAppear() {
    Task {
        do {
            let starred = try await repository.isStarred(
                owner: gitHubRepository.owner.login,
                name: gitHubRepository.name
            )
            isStarred = starred
            updateUIModel()
        } catch {
            print(error.localizedDescription)
        }
        isStarButtonEnabled = true
    }
}
```

### Combine

ViewModel が持つ表示状態を `@Published` で公開し、View はそれを購読するだけで表示が更新される形にしました。View 側に「どのタイミングで表示を更新するか」を書く必要がなく、ViewModel が状態を変えればそのまま描画に反映されます。

```swift
// ViewModel: 状態を公開する
@Published private(set) var state: ViewState = .initial
@Published private(set) var router: Router?
```

```swift
// View: 購読して表示を更新する
viewModel.$state
    .receive(on: DispatchQueue.main)
    .sink { [weak self] state in
        // 状態ごとに表示を切り替える
    }
    .store(in: &cancellables)
```

`@Published` は購読した時点で現在の値が流れてくるため、初期表示のために別の処理を書く必要がありません。購読を `viewDidLoad` で一度設定するだけで、検索前・検索中・結果・エラーのすべてが同じ経路で描画されます。

一方、View から ViewModel への入力はメソッド呼び出しで受け、検索の実行は `PassthroughSubject` に流して購読側で処理しています。`@Published` や `CurrentValueSubject` は初期値が必須で、購読を始めた時点でその値が流れます。検索の実行で使うと、まだ何も入力していないのに初期値で検索が走ってしまいます。そのため入力側は、値を保持せず `send` されたときだけ流れる `PassthroughSubject` にしました。

```swift
/// View からの検索文字列の送信口。
private let searchQuerySubmitted = PassthroughSubject<String, Never>()

init(repository: any RepositorySearchRepositoryProtocol = RepositorySearchRepository()) {
    self.repository = repository

    searchQuerySubmitted
        .sink { [weak self] query in
            guard let self else { return }
            Task { await self.search(query: query) }
        }
        .store(in: &cancellables)
}

/// 検索が実行されたことをこの ViewModel に伝える。
func didSubmitSearch(query: String) {
    searchQuerySubmitted.send(query)
}
```

また、購読側では `receive(on: DispatchQueue.main)` を明示し、UI の更新がメインスレッドで行われることをコード上で読み取れるようにしています。

### 参照

ViewModel は View を参照しない構成にしました。delegate も持たないため View → ViewModel の一方向の依存になり、両者の間に循環参照が生まれる経路がありません。

そのうえで、`sink` のクロージャには `[weak self]` を付けています。クロージャは購読が生きている間、内部の参照を保持し続けるためです。ViewModel では購読を自分の `cancellables` に保持しているため、クロージャで `self` を強参照すると循環参照になり解放されません。ViewController 側も同じ構造なので、購読がある間 ViewController が解放されなくなります。

```swift
// ViewModel: 購読を自分の cancellables に保持するため [weak self] を付ける
searchQuerySubmitted
    .sink { [weak self] query in
        guard let self else { return }
        Task { await self.search(query: query) }
    }
    .store(in: &cancellables)
```

```swift
// ViewController: 同じ構造なので、こちらも [weak self] を付ける
viewModel.$state
    .receive(on: DispatchQueue.main)
    .sink { [weak self] state in
        guard let self else { return }
        // 状態ごとに表示を切り替える
    }
    .store(in: &cancellables)
```


### エラー設計

API のエラーは `APIError` として型で表現し、ケース名でどこで何が起きたのかが分かるようにしました。GitHub のドキュメントで意味が定義されているステータスコードは、専用のケースに割り当てています。

```swift
enum APIError: Error {
    case invalidURL
    case invalidResponse
    /// GitHub APIが422を返した場合のエラー。バリデーションエラーとスパム防止によるリクエスト拒否の両方を意味しうる。
    case requestRejected
    /// GitHub APIのレートリミットを超過した場合のエラー（403 / 429）。
    case rateLimitExceeded
    /// GitHubのサービスが一時的に利用できない場合のエラー（503 Service Unavailable）。
    case serviceUnavailable
    /// 上記以外でステータスコードが 2xx 以外だった場合のエラー。
    case unacceptable(statusCode: Int)
    case urlSession(Error)
    case decode(Error)
}
```

`throws(APIError)` を使うことで、この層から投げられるエラーが `APIError` に限られることをシグネチャで示しています。ユーザーに見せる文言は `LocalizedError` の `errorDescription` に集約したため、ViewModel は `error.localizedDescription` を状態に載せるだけで済みます。

一方で、API の仕様としてエラーが返る箇所は Repository で変換しました。スター状態の確認は「スター済み = 204 / 未スター = 404」が返るため、404 を `false` に変換し、ステータスコードの知識を呼び出し側に持ち込ませないようにしています。

```swift
/// スター状態を取得する。204（スター済み）は true、404（未スター）は false に変換する。
func isStarred(owner: String, name: String) async throws(APIError) -> Bool {
    do {
        _ = try await apiClient.fetchStarStatus(GetStarStatusRequest(owner: owner, repo: name))
        return true
    } catch {
        if case .unacceptable(statusCode: 404) = error { return false }
        throw error
    }
}
```

検索の失敗をアラートで知らせるよう実装しましたが、詳細画面のスター操作の失敗は現時点ではログ出力のみで、ユーザーには通知していません。


### 疎結合

疎結合とは、モジュール同士の依存が弱い状態のことです。判断の目安は「片方を変えたときに、もう片方も変える必要があるか」です。

モデルは、層ごとに3つに分けました。API のレスポンスをそのまま受け取る `RepositoryResponse`、アプリ内でリポジトリを表す `GitHubRepository`、画面にそのまま表示できる `RepositoryRowUIModel` です。層をまたぐときは Translator で変換しています。

その結果、View が受け取るのは表示用の UIModel だけになり、`RepositoryCell` には `GitHubRepository` が1度も出てきません。API のレスポンス形状が変わっても、影響は `RepositoryResponse` と `RepositoryTranslator` に閉じ、View まで波及しません。

```swift
// セルが受け取るのは表示用の UIModel だけ
func configure(with repository: RepositoryRowUIModel) {
    nameLabel.text = repository.name
    descriptionLabel.text = repository.description
    starCountLabel.text = repository.starCountText
    ...
}
```


### 抽象化

抽象化とは、詳細を隠して本質だけを見せることです。使う側が知らなくていいことを見せないようにします。

ViewModel から見て何が隠れているかを整理すると、次のようになります。

| ViewModel が知らないこと | 隠している場所 |
| --- | --- |
| HTTP のステータスコード | `StarRepository`（404 を `false` に変換） |
| JSON のキー名（`stargazers_count` など） | `RepositoryResponse` と `RepositoryTranslator` |
| エンドポイントのパスや HTTP メソッド | `RequestType` に準拠した各構造体 |
| レスポンスボディがない成功（204） | `NoContent` という型 |

たとえばスター状態の確認は「スター済み = 204 / 未スター = 404」が返りますが、この知識は Repository で吸収しています。

```swift
/// スター状態を取得する。204（スター済み）は true、404（未スター）は false に変換する。
func isStarred(owner: String, name: String) async throws(APIError) -> Bool {
    do {
        _ = try await apiClient.fetchStarStatus(GetStarStatusRequest(owner: owner, repo: name))
        return true
    } catch {
        if case .unacceptable(statusCode: 404) = error { return false }
        throw error
    }
}
```

結果として ViewModel が扱うのは `[GitHubRepository]` と `Bool` だけになり、通信の詳細が画面側に現れません。

### 凝集度

凝集度とは、クラスやモジュールの中の機能が、どれだけ関連性の高い目的にまとまっているかを示す指標です。異なる関心事が混在している状態を低凝集、1つの責務に集中している状態を高凝集と呼び、高凝集なほど変更しやすく、再利用もしやすくなります。

型ごとの責務は1つに絞りました。たとえば `LanguageColor` は「言語名から色を返す」ことだけを担っており、それ以外の関心事を持っていません。

```swift
/// 主要言語ごとの色分け（GitHubの言語カラーに準拠した簡易マッピング）。
enum LanguageColor {
    static func color(for language: String) -> UIColor {
        colors[language] ?? .systemGray3
    }

    private static let colors: [String: UIColor] = [
        "Swift": color(hex: 0xF05138),
        "Python": color(hex: 0x3572A5),
        ...
    ]
}
```

この型を読むときに把握する必要があるのは、言語と色の対応だけです。色の追加や変更が必要になったときも、影響はこの型の中に収まります。


### DRY 原則

このアプリでは、DRY 原則を意識して開発を行いました。DRY（Don't Repeat Yourself）とは、同じ知識を複数の場所に持たないという原則です。同じコードを書かないことではなく、同じ知識が散らばって片方だけ修正される状態を避けることが目的だと理解しています。今回は、変更したときに触る場所が1か所に収まるよう意識しました。

まず、通信処理をエンドポイントごとに書かないよう、ジェネリクスで `send` を1つにまとめました。`RequestType` に準拠した型を受け取る形にしているため、エンドポイントが増えても通信処理は増えません。

ジェネリクスを使わない場合、検索・スター状態の確認・スターの付与・解除といったエンドポイントごとにメソッドを用意し、そのたびに同じ通信処理を書くことになります。

```swift
// リクエストの型を受け取り、戻り値の型も Request 側から決まる
func send<Request: RequestType>(_ request: Request) async throws(APIError) -> Request.Response
```

エラーの文言は `LocalizedError` の `errorDescription` に集約しました。ViewModel は `error.localizedDescription` を状態に載せるだけなので、文言を変えるときに触るのは `APIError` だけです。

```swift
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded:
            return "アクセスが集中しています。時間をおいて再度お試しください。"
        case .serviceUnavailable:
            return "GitHub のサービスが一時的に利用できません。時間をおいて再度お試しください。"
        ...
        }
    }
}
```

同じスタイルのラベルの生成も1か所にまとめました。詳細画面のフォーク数・Issue 数・更新日・トピックは同じ見た目なので、生成を `makeSubLabel()` に集約しています。フォントや行数を変えるときに4箇所を直す必要がありません。

```swift
private let forkCountLabel = RepositoryDetailViewController.makeSubLabel()
private let issueCountLabel = RepositoryDetailViewController.makeSubLabel()
private let updatedAtLabel = RepositoryDetailViewController.makeSubLabel()
private let topicsLabel = RepositoryDetailViewController.makeSubLabel()

/// fork数・issue数・更新日・topics 用の、少し小さめ（14pt）のサブ情報ラベルを生成する。
private static func makeSubLabel() -> UILabel {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.numberOfLines = 0
    return label
}
```

### APIClient

エンドポイントごとにメソッドを増やさず、`RequestType` を渡すだけで呼べる汎用の `send` を1つ用意しました。

```swift
func send<Request: RequestType>(_ request: Request) async throws(APIError) -> Request.Response
```

`associatedtype` で Response を結びつけているため、戻り値の型が Request 側で確定します。

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

### ViewState

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

### Router

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

### Repository

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

### Translator

モデルを API レスポンス → DataModel → UIModel の3段に分け、変換をそれぞれ Translator で行いました。その結果、整形や `nil` の穴埋めを View や ViewModel で行わず、View は整形済みの値をそのまま表示するだけでよくなります。

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

### Provider

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

データソースには DiffableDataSource を使い、`cellForItemAt` を実装する代わりに、表示したい状態をスナップショットとして渡す形にしました。差分は DiffableDataSource が計算するため、`reloadData()` を呼ばずに変化した行だけが更新されることも学びました。

### iOS 26 での検索バーの配置（preferredSearchBarPlacement）

|iOS 18 以前|iOS 26（.stacked 指定前）|iOS 26（.stacked 指定後）|
|---|---|---|
|<img width="1170" height="2532" alt="Simulator Screenshot - iPhone 16e - 2026-07-17 at 20 09 44" src="https://github.com/user-attachments/assets/db2bc3ef-aeb7-46e0-9e69-87771478c6f7" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-07-21 at 09 52 58" src="https://github.com/user-attachments/assets/cfe7a713-8d78-43c4-baa8-e306d84db2f2" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-06 at 13 03 14" src="https://github.com/user-attachments/assets/b540093b-ba07-4f24-9240-1565bc318f02" />|

`UISearchController` を `navigationItem.searchController` に載せる実装にしましたが、iOS 18 以前では検索バーがデフォルトで画面上部に配置され、iOS 26 では画面下部に配置されます。OS の違いで検索バーの位置が異なる実装は望ましくないと考えたため、上部に固定するよう配置を明示的に指定しました。

```swift
navigationItem.searchController = searchController
// iOS 26 では検索バーの配置がデフォルトで画面下部になるため、
// OS間で見た目が変わらないようナビゲーションバーを画面上部に固定する。
if #available(iOS 26.0, *) {
    navigationItem.preferredSearchBarPlacement = .stacked
}
```

`.stacked` はナビゲーションタイトルの下に検索バーを積む配置です。同じコードでも OS のバージョンによって既定の見た目が変わることがあり、新しい OS の既定値を確認して、意図した配置を明示する必要があることを学びました。

### AI が出力したコードのセルフレビュー

着手当初は、AI が出力したコードの安全性を十分にレビューしないままレビュー依頼を出してしまい、多くの指摘をいただくことがありました。そこで以降は、差分を一つずつ目視で確認し、その実装が本当に正しいのかを調査したうえで依頼する、というプロセスをセルフレビューに組み込みました。さらに複数の AI ツールのレビュー機能を活用することで、自分では気づけない観点を補いました。

その結果、指摘されるコメントの数を減らすことができ、AI が出力したコードをそのまま信頼せず、意図どおりの実装になっているかを自分で確認したうえで依頼する必要があることを学びました。

## 感想・振り返り

今回の課題で一番の経験になったのは、MVVM + Repository のアーキテクチャで実装したことです。これまでは MVP での実装が中心で、ほかのアーキテクチャを自分で組んだことがありませんでした。そのため、普段使っている MVP についても、どこが優れていてどこに難しさがあるのかを比べて捉えることができていませんでした。今回 MVVM + Repository で実装したことで、MVP の良さと、逆にデメリットだと感じる点の両方を理解できたことが、一番の学びです。

もう1つは通信部分の実装です。`URLSession` を使って API を呼ぶ実装や、API クライアントを自作してエンドポイントを叩く実装は、これまでほとんど経験がありませんでした。今回ライブラリを使わずに自分で `APIClient` を組んだことで、リクエストの組み立てからレスポンスのデコード、エラーハンドリングまでの流れを理解し、実装できるようになりました。

次に取り組みたいのはユニットテストの実装です。Repository や Translator を層として分け、依存をプロトコルで注入する形にしたことで、テストを書きやすい構成にはできたと考えています。一方でテスト自体は今回実装できていないため、次はこの構成を活かして、ViewModel の状態遷移や Translator の変換を検証するテストコードを書くところまでやりたいと思っています。
