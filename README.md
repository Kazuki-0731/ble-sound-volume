# BLE Sound Volume

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4CAF50?style=flat)](https://flutter.dev)
[![macOS](https://img.shields.io/badge/macOS-13.0+-9B59B6?style=flat&logo=apple)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.0+-FA7343?style=flat&logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)](LICENSE)
[![BLE](https://img.shields.io/badge/BLE-4.0+-1E90FF?style=flat&logo=bluetooth)](https://www.bluetooth.com)

Bluetooth Low Energy (BLE)通信を使用してmacOSの音量を遠隔操作するFlutterアプリケーションです。

## 概要

このシステムは、Android/iOSモバイルアプリケーションからBLE通信を使用してmacBookのシステム音量をリアルタイムで制御できます。ユーザーはモバイルデバイス上のスライダーやボタンを使用して、接続されたmacBookの音量を直感的に調整できます。

## 主な機能

- 🔍 **デバイススキャン**: Bluetooth範囲内のmacOSデバイスを検索・発見
- 🔗 **BLE接続**: 発見したデバイスへの接続と自動再接続
- 🎚️ **音量制御**: スライダーを使用した直感的な音量調整（0-100%）
- 🔇 **ミュート機能**: ワンタップでミュート/ミュート解除
- 📊 **リアルタイム同期**: macOS側の音量変更をモバイルアプリに自動反映
- 📳 **ハプティックフィードバック**: 音量調整時の触覚フィードバック
- 🔄 **自動再接続**: 接続切断時の自動再接続（最大3回、5秒間隔）

## アーキテクチャ

### システム構成

```
┌─────────────────────────────┐         ┌─────────────────────────────┐
│    Mobile App (Flutter)     │         │      macOS Host (Swift)     │
│                             │         │                             │
│  ┌───────────────────────┐ │         │  ┌───────────────────────┐ │
│  │    UI Layer           │ │         │  │   BLE Service         │ │
│  │  - DeviceScanScreen   │ │         │  │   (Peripheral)        │ │
│  │  - VolumeControlScreen│ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │             │              │
│             │               │   BLE   │             │              │
│  ┌───────────────────────┐ │◄───────►│  ┌───────────────────────┐ │
│  │   BLoC Layer          │ │  GATT   │  │  Volume Controller    │ │
│  │  - VolumeControlBloc  │ │         │  │  (CoreAudio)          │ │
│  │  - DeviceScanBloc     │ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │             │              │
│             │               │         │             ▼              │
│  ┌───────────────────────┐ │         │  ┌───────────────────────┐ │
│  │  Repository Layer     │ │         │  │   macOS Audio System  │ │
│  │  - BleRepositoryImpl  │ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │                             │
└─────────────────────────────┘         └─────────────────────────────┘
```

### BLE GATT プロファイル

**サービスUUID**: `12345678-1234-1234-1234-123456789ABC`

**キャラクタリスティック**:
- **音量レベル** (`12345678-1234-1234-1234-123456789ABD`)
  - Type: UInt8 (0-100)
  - Properties: Read, Write, Notify

- **ミュート状態** (`12345678-1234-1234-1234-123456789ABE`)
  - Type: UInt8 (0=unmuted, 1=muted)
  - Properties: Read, Write, Notify

## 技術スタック

### モバイルアプリ (Flutter)

- **Flutter** - クロスプラットフォームUIフレームワーク
- **flutter_blue_plus** (^1.32.0) - BLE通信
- **flutter_bloc** (^8.1.0) - 状態管理
- **equatable** (^2.0.0) - 値の比較
- **permission_handler** (^11.0.0) - 権限管理

### macOSホスト (Swift)

- **CoreBluetooth** - BLE実装
- **CoreAudio** - システム音量制御
- **SwiftUI** - メニューバーアプリUI

## セットアップ

### 前提条件

- Flutter SDK 3.0以上
- Xcode 15.0以上（macOSアプリのビルド用）
- Android Studio / VS Code
- macOS 13.0以上（ホストアプリ実行用）

### モバイルアプリのセットアップ

1. リポジトリをクローン
```bash
git clone https://github.com/yourusername/ble-sound-volume.git
cd ble-sound-volume
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. iOS用のCocoaPodsをインストール
```bash
cd ios
pod install
cd ..
```

4. アプリを実行
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### macOSホストアプリのセットアップ

#### 開発中の実行（Xcode経由）

1. Xcodeでプロジェクトを開く
```bash
cd macos_host/MacVolumeControl
open MacVolumeControl.xcodeproj
```

2. プロジェクトをビルドして実行
   - Xcodeで `Product > Run` を選択
   - メニューバーにアイコンが表示されます

#### スタンドアローンアプリとしてビルド（Xcode不要で動作）

**方法1: Xcodeでアーカイブ（推奨）**

1. Xcodeで `Product > Archive` を選択
2. `Distribute App` > `Copy App` を選択
3. エクスポートされた `.app` ファイルを `アプリケーション` フォルダにコピー
4. Finderからアプリをダブルクリックして起動

**方法2: コマンドラインでビルド**

```bash
cd macos_host/MacVolumeControl
xcodebuild -project MacVolumeControl.xcodeproj \
  -scheme MacVolumeControl \
  -configuration Release \
  -derivedDataPath ./build

# ビルドされたアプリをコピー
cp -r ./build/Build/Products/Release/MacVolumeControl.app ~/Applications/
```

**ログイン時に自動起動（任意）:**
- `システム設定` > `一般` > `ログイン項目` から `MacVolumeControl.app` を追加

詳細は [macOSホストアプリのREADME](macos_host/README.md) を参照してください。

## 使い方

### 1. macOSホストアプリを起動

macOSデバイスでMacVolumeControlアプリを起動します。メニューバーにアイコンが表示され、BLEサービスのアドバタイジングが開始されます。

### 2. モバイルアプリでデバイスをスキャン

1. モバイルアプリを起動
2. 「デバイスをスキャン」ボタンをタップ
3. Bluetooth権限を許可
4. 発見されたデバイスリストからmacOSデバイスを選択

### 3. 音量を制御

- **スライダー**: ドラッグして音量を調整（0-100%）
- **ミュートボタン**: タップしてミュート/ミュート解除
- **接続状態**: 画面上部に接続状態が表示されます

### 4. 切断

「切断」ボタンをタップするか、アプリを終了すると接続が切断されます。

## テスト

### ユニットテストの実行

```bash
flutter test
```

### テストカバレッジ

- BLoC状態遷移テスト
- デバウンス処理テスト
- エラーハンドリングテスト
- UI ウィジェットテスト

## エラーハンドリング

### モバイルアプリ

- **Bluetooth無効**: 設定画面へのナビゲーションを提供
- **接続失敗**: 3回まで自動リトライ（5秒間隔）
- **通信タイムアウト**: 書き込み3秒、読み取り2秒
- **無効な音量値**: 0-100の範囲にクランプ

### macOSホスト

- **Bluetooth権限なし**: 権限リクエストダイアログを表示
- **無効なコマンド**: 範囲チェックとログ記録
- **Audio Systemエラー**: エラーをキャッチして前回の正常値を保持

## パフォーマンス最適化

- **デバウンス処理**: スライダー操作時に100msのデバウンスでBLE通信を削減
- **通知の最適化**: 音量が実際に変更された場合のみ通知を送信
- **低消費電力**: BLE 4.0+の省電力機能を活用

## セキュリティ

- BLE接続時のペアリング（Just Works方式）
- 同時接続数を1デバイスに制限
- 受信データの範囲バリデーション
- Bluetooth権限の適切な管理

## プロジェクト構造

```
ble-sound-volume/
├── lib/
│   ├── bloc/              # BLoC状態管理
│   ├── models/            # データモデル
│   ├── repositories/      # BLEリポジトリ
│   ├── screens/           # UI画面
│   └── main.dart
├── macos_host/
│   └── MacVolumeControl/  # macOSホストアプリ
├── test/                  # テストコード
└── .kiro/
    └── specs/             # 仕様書・設計書
```

## ライセンス

MIT License

## 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 関連ドキュメント

- [要件定義書](.kiro/specs/mac-volume-control/requirements.md)
- [設計書](.kiro/specs/mac-volume-control/design.md)
- [実装タスク](.kiro/specs/mac-volume-control/tasks.md)
- [macOSホスト実装ノート](macos_host/IMPLEMENTATION_NOTES.md)

## お問い合わせ

問題や質問がある場合は、GitHubのIssuesページでお知らせください。
