# Implementation Plan

- [x] 1. プロジェクトのセットアップと依存関係の追加
  - pubspec.yamlにflutter_blue_plus、flutter_bloc、equatable、permission_handlerを追加
  - 必要なパッケージをインストール
  - Android/iOSのBluetooth権限設定を追加（AndroidManifest.xml、Info.plist）
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. データモデルとエンティティの実装
  - [x] 2.1 VolumeDataモデルクラスを作成
    - level、isMuted、timestampプロパティを定義
    - Equatableを継承して値の比較を実装
    - _Requirements: 2.3, 3.5, 4.4_
  
  - [x] 2.2 ConnectionStateモデルクラスを作成
    - isConnected、deviceName、deviceId、errorMessageプロパティを定義
    - _Requirements: 1.2, 1.4, 6.1_

- [x] 3. BLEリポジトリ層の実装
  - [x] 3.1 BleRepositoryインターフェースを定義
    - scanForDevices、connect、disconnect、volumeStream、setVolume、toggleMute、getCurrentVolumeメソッドを宣言
    - _Requirements: 1.1, 1.3, 2.1, 3.2, 4.2_
  
  - [x] 3.2 BleRepositoryImplクラスを実装
    - flutter_blue_plusを使用してデバイススキャン機能を実装
    - BLE接続/切断ロジックを実装
    - カスタムサービスUUIDとキャラクタリスティックUUIDを定義
    - 音量読み取り、書き込み、通知購読を実装
    - _Requirements: 1.1, 1.3, 2.1, 2.2, 3.2, 3.3, 4.2, 4.3, 5.3_
  
  - [x] 3.3 再接続ロジックを実装
    - 接続切断時の自動再接続（最大3回、5秒間隔）
    - リソースのクリーンアップ処理
    - _Requirements: 6.2, 6.3, 6.4, 6.5_

- [x] 4. BLoC状態管理の実装
  - [x] 4.1 VolumeStateとVolumeEventクラスを定義
    - sealed classを使用してVolumeDisconnected、VolumeConnecting、VolumeConnected、VolumeErrorを定義
    - ConnectToDevice、DisconnectFromDevice、SetVolumeLevel、ToggleMuteState、VolumeUpdatedFromDeviceイベントを定義
    - _Requirements: 1.2, 1.4, 1.5, 2.3, 3.1, 4.1, 6.1_
  
  - [x] 4.2 VolumeControlBlocを実装
    - 各イベントに対する状態遷移ロジックを実装
    - BleRepositoryを使用してBLE操作を実行
    - 音量変更のデバウンス処理（100ms）を実装
    - エラーハンドリングとタイムアウト処理を実装
    - _Requirements: 1.3, 1.4, 2.1, 2.4, 3.2, 3.4, 4.2, 4.4_
  
  - [x] 4.3 DeviceScanBlocを実装
    - ScanStateとScanEventを定義
    - デバイススキャンの開始/停止ロジックを実装
    - 発見されたデバイスのリスト管理
    - _Requirements: 1.1, 1.2_

- [x] 5. UI層の実装
  - [x] 5.1 DeviceScanScreenを作成
    - スキャン開始ボタンとローディングインジケーターを実装
    - 発見されたデバイスのリスト表示
    - デバイス選択時の接続処理
    - Bluetooth権限チェックとリクエスト
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 5.2 VolumeControlScreenを作成
    - 接続状態表示ウィジェットを実装
    - 音量スライダーウィジェットを実装（0-100の範囲）
    - ミュート/ミュート解除ボタンを実装
    - 切断ボタンを実装
    - _Requirements: 1.5, 2.3, 3.1, 4.1, 4.4_
  
  - [x] 5.3 BlocProviderとBlocBuilderを統合
    - VolumeControlBlocとDeviceScanBlocをウィジェットツリーに提供
    - 状態に応じたUI更新を実装
    - エラー表示とスナックバー通知を実装
    - _Requirements: 1.4, 2.4, 6.1_
  
  - [x] 5.4 ハプティックフィードバックを追加
    - 音量調整時の触覚フィードバックを実装
    - _Requirements: 3.4_

- [x] 6. macOSホストアプリケーションの実装
  - [x] 6.1 Xcodeプロジェクトを作成
    - macOSメニューバーアプリのプロジェクトを新規作成
    - CoreBluetoothとCoreAudioフレームワークを追加
    - Info.plistにBluetooth使用説明を追加
    - _Requirements: 5.1, 5.2_
  
  - [x] 6.2 MacVolumeControllerクラスを実装
    - CoreAudioを使用してgetVolume、setVolume、getMuteState、setMuteStateメソッドを実装
    - AudioObjectPropertyListenerを使用して音量変更の監視を実装
    - _Requirements: 2.2, 3.3, 4.3, 5.4_
  
  - [x] 6.3 VolumeControlPeripheralクラスを実装
    - CBPeripheralManagerを使用してBLEペリフェラルを初期化
    - カスタムサービスとキャラクタリスティック（Volume、Mute）を定義
    - Read、Write、Notifyリクエストのハンドラーを実装
    - 受信した音量値のバリデーション（0-100の範囲チェック）を実装
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [x] 6.4 音量変更の通知機能を実装
    - MacVolumeControllerからの音量変更イベントを受信
    - 接続中のクライアントにBLE通知を送信
    - _Requirements: 2.2, 4.3_
  
  - [x] 6.5 メニューバーUIを実装
    - SwiftUIを使用してメニューバーアイコンとメニューを作成
    - 接続状態の表示
    - アプリの終了オプション
    - _Requirements: 5.1_

- [x] 7. エラーハンドリングと権限管理の実装
  - [x] 7.1 モバイルアプリの権限チェックを実装
    - permission_handlerを使用してBluetooth権限をチェック
    - 権限がない場合は設定画面へのナビゲーションを提供
    - _Requirements: 1.1_
  
  - [x] 7.2 接続エラーハンドリングを実装
    - タイムアウト処理（書き込み3秒、読み取り2秒）
    - エラーメッセージの表示
    - リトライロジック
    - _Requirements: 1.4, 6.2, 6.3, 6.4_
  
  - [x] 7.3 macOSアプリの権限チェックを実装
    - Bluetooth権限の確認とリクエスト
    - 権限がない場合のエラー通知
    - _Requirements: 5.1_

- [x] 8. アプリの統合とワイヤリング
  - [x] 8.1 main.dartを更新
    - BlocProviderを設定
    - 初期画面をDeviceScanScreenに設定
    - アプリテーマとナビゲーションを設定
    - _Requirements: 1.1_
  
  - [x] 8.2 依存性注入を設定
    - BleRepositoryのインスタンスを作成
    - BLoCにリポジトリを注入
    - _Requirements: すべて_
  
  - [x] 8.3 画面遷移を実装
    - DeviceScanScreenからVolumeControlScreenへの遷移
    - 切断時のDeviceScanScreenへの戻り
    - _Requirements: 1.3, 1.5, 6.4_

- [-] 9. テストの作成
  - [x] 9.1 BleRepositoryのモックを作成
    - Mockitoを使用してBleRepositoryのモック実装を作成
    - _Requirements: すべて_
  
  - [x] 9.2 VolumeControlBlocのユニットテストを作成
    - 各イベントに対する状態遷移をテスト
    - デバウンス処理をテスト
    - エラーハンドリングをテスト
    - _Requirements: 1.3, 1.4, 2.1, 3.2, 4.2_
  
  - [x] 9.3 UI ウィジェットテストを作成
    - DeviceScanScreenのウィジェットテスト
    - VolumeControlScreenのウィジェットテスト
    - _Requirements: 1.1, 1.2, 2.3, 3.1, 4.1_
