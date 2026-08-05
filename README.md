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

#### 表示状態の一元化（ViewState）

#### 画面遷移の責務分離（Router）

#### データ取得の抽象化（Repository）

#### モデル変換の集約（Translator）

#### 遷移先の初期化と依存注入の集約（Provider）

### APIClient の汎用化（Generics + associatedtype）

### 一覧画面の描画（CompositionalLayout + DiffableDataSource）

## 新しく学んだこと

### UICollectionLayoutListConfiguration を用いて設定画面風に実装

### iOS 26 での検索バーの配置（preferredSearchBarPlacement）

## 今後の課題
