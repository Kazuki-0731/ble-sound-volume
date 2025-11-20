# Contributing to BLE Sound Volume

BLE Sound Volumeへの貢献を検討していただき、ありがとうございます！
このドキュメントでは、プロジェクトへの貢献方法についてのガイドラインを提供します。

## 行動規範

このプロジェクトは[Code of Conduct](CODE_OF_CONDUCT.md)を採用しています。参加することで、このコードを守ることに同意したものとみなされます。

## 貢献方法

### バグ報告

バグを見つけた場合は、[GitHub Issues](https://github.com/Kazuki-0731/ble-sound-volume/issues)で報告してください。

報告には以下の情報を含めてください：

1. **バグの説明** - 何が起こったかを明確に説明
2. **再現手順** - バグを再現するための詳細な手順
3. **期待される動作** - 本来どのように動作すべきか
4. **実際の動作** - 実際に何が起こったか
5. **スクリーンショット** - 可能であれば添付
6. **環境情報**
   - モバイルアプリの場合: OS、デバイス、Flutterバージョン
   - macOSホストの場合: macOSバージョン、Xcodeバージョン

### 機能リクエスト

新しい機能のアイデアがある場合は、[GitHub Issues](https://github.com/Kazuki-0731/ble-sound-volume/issues)で提案してください。

以下を含めてください：

- **機能の説明** - どのような機能を追加したいか
- **ユースケース** - なぜこの機能が必要か、どのように使用されるか
- **実装の提案** - 技術的な実装方法のアイデア（任意）

### コードの貢献

プルリクエストは大歓迎です！以下の手順に従ってください。

## 開発環境

### 必要なツール

#### モバイルアプリ開発
- Flutter SDK 3.0以上
- Dart 3.0以上
- Android Studio / VS Code
- Xcode 15.0以上（iOS開発の場合）

#### macOSホストアプリ開発
- Xcode 15.0以上
- macOS 13.0以上

### セットアップ手順

1. **リポジトリをフォーク**

   GitHubでこのリポジトリをフォークします。

2. **クローン**

   ```bash
   git clone https://github.com/YOUR_USERNAME/ble-sound-volume.git
   cd ble-sound-volume
   ```

3. **依存関係のインストール**

   ```bash
   # Flutter依存関係
   flutter pub get

   # iOS CocoaPods（iOS開発の場合）
   cd ios
   pod install
   cd ..
   ```

4. **動作確認**

   ```bash
   # モバイルアプリの実行
   flutter run

   # テストの実行
   flutter test
   ```

### ブランチ戦略

このプロジェクトは**GitHub Flow**を採用しています。

1. **最新のmainブランチを取得**

   ```bash
   git checkout main
   git pull origin main
   ```

2. **機能ブランチを作成**

   ```bash
   # 新機能の場合
   git checkout -b feature/your-feature-name

   # バグ修正の場合
   git checkout -b fix/bug-description

   # ドキュメント更新の場合
   git checkout -b docs/documentation-update
   ```

3. **変更を実装**

   コーディング規約に従って実装してください。

4. **コミット**

   ```bash
   git add .
   git commit -m "✨ 新機能: 機能の説明"
   ```

5. **プッシュ**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **プルリクエストを作成**

   GitHubでプルリクエストを作成し、テンプレートに従って記入してください。

### コーディング規約

#### Dart（モバイルアプリ）

- [Effective Dart](https://dart.dev/guides/language/effective-dart)に従う
- `flutter format .`でコードをフォーマット
- `flutter analyze`で静的解析を実行
- 関数やクラスにドキュメントコメントを追加

例：
```dart
/// BLEデバイスに接続します
///
/// [device] 接続先のBluetoothDevice
/// 接続に失敗した場合は例外をスローします
Future<void> connect(BluetoothDevice device) async {
  // 実装
}
```

#### Swift（macOSホストアプリ）

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)に従う
- Xcodeのフォーマッターを使用
- 関数やクラスにドキュメントコメントを追加

例：
```swift
/// システム音量を取得します
/// - Returns: 0.0〜1.0の範囲の音量値
func getVolume() -> Float {
    // 実装
}
```

### コミットメッセージ

コミットメッセージは以下の形式に従ってください：

```
<絵文字> <タイトル>

<詳細な説明（必要に応じて）>
```

#### 絵文字ガイド

| 絵文字 | コード | 用途 |
|--------|--------|------|
| ✨ | `:sparkles:` | 新機能 |
| 🐛 | `:bug:` | バグ修正 |
| 📝 | `:memo:` | ドキュメント |
| 🎨 | `:art:` | UI/UXの改善 |
| ♻️ | `:recycle:` | リファクタリング |
| ⚡ | `:zap:` | パフォーマンス改善 |
| ✅ | `:white_check_mark:` | テスト追加 |
| 🔧 | `:wrench:` | 設定ファイル変更 |
| 🚀 | `:rocket:` | デプロイ・リリース |
| 🔒 | `:lock:` | セキュリティ修正 |

例：
```bash
git commit -m "✨ BLE接続の再接続機能を追加"
git commit -m "🐛 音量設定時のクラッシュを修正"
git commit -m "📝 README.mdにセットアップ手順を追加"
```

## テスト

### ユニットテスト

変更後は必ずテストを実行してください：

```bash
# すべてのテストを実行
flutter test

# テストカバレッジを確認
flutter test --coverage

# 特定のテストファイルのみ実行
flutter test test/bloc/volume_control_bloc_test.dart
```

### テストの追加

新しい機能を追加する場合は、対応するテストも追加してください：

```dart
test('音量が正しく設定される', () async {
  // テストコード
});
```

### 手動テスト

UI/UXの変更がある場合は、実機での動作確認も行ってください：

```bash
# Android実機で実行
flutter run

# iOS実機で実行
flutter run -d ios

# macOSホストアプリをビルド
cd macos_host/MacVolumeControl
xcodebuild -project MacVolumeControl.xcodeproj \
  -scheme MacVolumeControl \
  -configuration Release
```

## ドキュメント

### ドキュメントの更新

コードの変更に伴い、関連するドキュメントも更新してください：

- `README.md` - プロジェクトの概要や使い方
- `CONTRIBUTING.md` - 貢献ガイドライン（このファイル）
- `macos_host/README.md` - macOSホストアプリの説明
- `.kiro/specs/` - 仕様書や設計書

### コメントの追加

複雑なロジックには日本語でコメントを追加してください：

```dart
// BLE接続が切断された場合、最大3回まで再接続を試みる
for (var i = 0; i < maxRetries; i++) {
  try {
    await _reconnect();
    break;
  } catch (e) {
    if (i == maxRetries - 1) rethrow;
  }
}
```

## プルリクエストのプロセス

1. **PRテンプレートに従う**

   プルリクエストを作成すると、テンプレートが表示されます。すべての項目を記入してください。

2. **CI/CDの通過を確認**

   GitHub Actionsが自動的にテストとビルドを実行します。すべてのチェックが通過することを確認してください。

3. **レビューを受ける**

   メンテナーがコードレビューを行います。変更が必要な場合は、同じブランチに追加のコミットをプッシュしてください。

4. **マージ**

   レビューが承認されると、メンテナーがmainブランチにマージします。

## 開発のヒント

### モバイルアプリの開発

```bash
# ホットリロード（状態を保持したまま再読み込み）
r

# ホットリスタート（状態をリセットして再起動）
R

# デバッグ情報を表示
flutter run --verbose

# リリースビルドを作成
flutter build apk  # Android
flutter build ios  # iOS
```

### macOSホストアプリの開発

```bash
# Xcodeで開く
cd macos_host/MacVolumeControl
open MacVolumeControl.xcodeproj

# コマンドラインでビルド
xcodebuild -project MacVolumeControl.xcodeproj \
  -scheme MacVolumeControl \
  -configuration Debug \
  build
```

### コードフォーマット

```bash
# Dartコードのフォーマット
flutter format .

# フォーマットの確認（変更しない）
flutter format --output=none --set-exit-if-changed .

# 静的解析
flutter analyze
```

### デバッグ

```bash
# Flutter DevToolsを起動
flutter pub global activate devtools
flutter pub global run devtools

# ログの確認
flutter logs
```

## 質問がある場合

質問やサポートが必要な場合は、以下の方法でお問い合わせください：

- [GitHub Issues](https://github.com/Kazuki-0731/ble-sound-volume/issues)で質問を投稿
- [GitHub Discussions](https://github.com/Kazuki-0731/ble-sound-volume/discussions)でコミュニティと議論（有効な場合）

## ライセンス

このプロジェクトに貢献することで、あなたの貢献が[MIT License](LICENSE)の下でライセンスされることに同意したものとみなされます。

---

再度、BLE Sound Volumeへの貢献を検討していただき、ありがとうございます！
あなたの貢献がプロジェクトをより良いものにします 🎉
