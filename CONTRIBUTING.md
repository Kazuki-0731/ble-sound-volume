# Contributing to BLE Sound Volume

まず、このプロジェクトへの貢献を検討していただきありがとうございます！

## 行動規範

このプロジェクトは[Code of Conduct](CODE_OF_CONDUCT.md)を採用しています。参加することで、このコードを守ることに同意したものとみなされます。

## 貢献方法

### バグ報告

バグを見つけた場合は、GitHubのIssuesで報告してください。以下の情報を含めてください：

- バグの説明
- 再現手順
- 期待される動作
- 実際の動作
- スクリーンショット（該当する場合）
- 環境情報（OS、Flutterバージョン、デバイスなど）

### 機能リクエスト

新しい機能のアイデアがある場合は、GitHubのIssuesで提案してください。以下を含めてください：

- 機能の説明
- ユースケース
- 実装の提案（任意）

### プルリクエスト

プルリクエストは歓迎します！以下の手順に従ってください：

#### 1. 開発環境のセットアップ

```bash
# リポジトリをフォーク
# フォークしたリポジトリをクローン
git clone https://github.com/YOUR_USERNAME/ble-sound-volume.git
cd ble-sound-volume

# 依存関係をインストール
flutter pub get

# iOS用CocoaPodsをインストール
cd ios && pod install && cd ..
```

#### 2. ブランチの作成

GitHub Flowに従い、`main`ブランチから機能ブランチを作成します：

```bash
# 最新のmainブランチを取得
git checkout main
git pull origin main

# 機能ブランチを作成
git checkout -b feature/your-feature-name

# または、バグ修正の場合
git checkout -b fix/bug-description
```

#### 3. コーディング規約

- **Dart**: [Effective Dart](https://dart.dev/guides/language/effective-dart)に従う
- **Swift**: [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)に従う
- コミットメッセージは絵文字から始める（例: `✨ 新機能を追加`、`🐛 バグを修正`）
- 英語で考え、日本語でコメントとコミットメッセージを書く

#### 4. テストの実行

変更後は必ずテストを実行してください：

```bash
# Flutterテストを実行
flutter test

# テストカバレッジを確認
flutter test --coverage
```

#### 5. コミット

変更をコミットします：

```bash
git add .
git commit -m "✨ 新機能: あなたの機能の説明"
```

コミットメッセージの絵文字ガイド：
- ✨ `:sparkles:` - 新機能
- 🐛 `:bug:` - バグ修正
- 📝 `:memo:` - ドキュメント
- 🎨 `:art:` - UIの改善
- ♻️ `:recycle:` - リファクタリング
- ⚡ `:zap:` - パフォーマンス改善
- ✅ `:white_check_mark:` - テスト追加
- 🔧 `:wrench:` - 設定ファイル変更

#### 6. プルリクエストの作成

```bash
# 変更をプッシュ
git push origin feature/your-feature-name
```

GitHubでプルリクエストを作成し、以下を含めてください：

- 変更内容の説明
- 関連するIssue番号（`Closes #123`など）
- テスト結果のスクリーンショット（該当する場合）
- 破壊的変更がある場合はその旨を明記

#### 7. レビュー

メンテナーがレビューします。変更が必要な場合は、同じブランチに追加のコミットをプッシュしてください。

## 開発のヒント

### モバイルアプリの開発

```bash
# Android
flutter run

# iOS
flutter run -d ios

# ホットリロード
r

# ホットリスタート
R
```

### macOSホストアプリの開発

```bash
cd macos_host/MacVolumeControl
open MacVolumeControl.xcodeproj
# Xcodeでビルド・実行
```

### コードフォーマット

```bash
# Dartコードをフォーマット
flutter format .

# 静的解析
flutter analyze
```

## リリースプロセス

1. バージョン番号を更新（`pubspec.yaml`）
2. CHANGELOG.mdを更新
3. `main`ブランチにマージ
4. タグを作成（`v1.0.0`形式）
5. GitHubリリースを作成

## 質問やサポート

質問がある場合は、GitHubのIssuesで質問してください。

## ライセンス

このプロジェクトに貢献することで、あなたの貢献が[MIT License](LICENSE)の下でライセンスされることに同意したものとみなされます。
