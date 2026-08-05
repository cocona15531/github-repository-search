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

## セットアップ

## アーキテクチャ
<img width="4000" height="2240" alt="アプリアーキテクチャ統合図" src="https://github.com/user-attachments/assets/1925e3a8-d9f9-4bd0-bd1d-b6840ecc9406" />


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
