# Mac Volume Control - macOS Host Application

This is the macOS host application that runs as a menu bar app and provides BLE peripheral functionality for remote volume control.

## Features

- Runs as a menu bar application
- Advertises BLE service for volume control
- Supports volume read, write, and notifications
- Supports mute/unmute functionality
- Real-time system volume monitoring
- Automatic notification to connected mobile devices

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Bluetooth enabled

## Building the Application

### 開発中の実行（Xcode経由）

1. Xcodeプロジェクトを開く:
   ```bash
   cd macos_host/MacVolumeControl
   open MacVolumeControl.xcodeproj
   ```

2. "MacVolumeControl" スキームとMacをターゲットデバイスとして選択

3. アプリケーションをビルドして実行 (⌘R)

### スタンドアローンアプリとしてビルド

Xcode外でも動作する独立したアプリケーションをビルドする方法：

#### 方法1: Xcodeでアーカイブしてエクスポート（推奨）

1. Xcodeでプロジェクトを開く

2. メニューバーから `Product` > `Archive` を選択

3. アーカイブが完了したら、Organizerウィンドウが開く

4. `Distribute App` をクリック

5. 配布方法を選択:
   - **Copy App**: 自分のMacだけで使う場合（最も簡単）
   - **Developer ID**: 他のMacでも実行できるように署名する場合（Apple Developer Program必要）

6. エクスポートされた `.app` ファイルを `アプリケーション` フォルダにコピー

7. Finderからアプリをダブルクリックして起動

#### 方法2: コマンドラインでビルド

```bash
# プロジェクトディレクトリに移動
cd macos_host/MacVolumeControl

# Releaseビルドを作成
xcodebuild -project MacVolumeControl.xcodeproj \
  -scheme MacVolumeControl \
  -configuration Release \
  -derivedDataPath ./build

# ビルドされたアプリの場所
# ./build/Build/Products/Release/MacVolumeControl.app

# アプリケーションフォルダにコピー（任意）
cp -r ./build/Build/Products/Release/MacVolumeControl.app ~/Applications/
```

#### アプリの起動方法

**アプリケーションフォルダから起動:**
```bash
open ~/Applications/MacVolumeControl.app
```

または、Finderで `MacVolumeControl.app` をダブルクリック

**ログイン時に自動起動（任意）:**
1. `システム設定` > `一般` > `ログイン項目` を開く
2. `+` ボタンをクリック
3. `MacVolumeControl.app` を選択
4. 追加

**メニューバーに常駐:**
アプリを起動すると、メニューバーにスピーカーアイコンが表示されます。Dockには表示されません（LSUIElement設定により）。

### 開発者署名なしで実行する場合

初回起動時に「開発元を確認できないため開けません」というエラーが出る場合:

1. `システム設定` > `プライバシーとセキュリティ` を開く
2. 「このまま開く」ボタンをクリック

または:
```bash
# 署名の検証を解除（自己責任で）
xattr -cr ~/Applications/MacVolumeControl.app
```

## Permissions

The application requires the following permissions:
- **Bluetooth**: To advertise BLE service and communicate with mobile devices
- **Audio**: To control system volume

These permissions are automatically requested when the app first launches.

## BLE Service Specification

**Service UUID**: `12345678-1234-1234-1234-123456789ABC`

**Characteristics**:
- **Volume Level** (`12345678-1234-1234-1234-123456789ABD`)
  - Type: UInt8 (0-100)
  - Properties: Read, Write, Notify
  
- **Mute State** (`12345678-1234-1234-1234-123456789ABE`)
  - Type: UInt8 (0=unmuted, 1=muted)
  - Properties: Read, Write, Notify

## Usage

1. Launch the application - it will appear in the menu bar with a speaker icon
2. Click the menu bar icon to view connection status and current volume
3. The app will automatically advertise its BLE service as "Mac Volume Control"
4. Connect from your mobile device using the Flutter app
5. Control volume remotely from your mobile device

## Architecture

- **MacVolumeController**: Interfaces with CoreAudio to control system volume
- **VolumeControlPeripheral**: Manages BLE peripheral and GATT service
- **ContentView**: SwiftUI-based menu bar popover interface
- **MacVolumeControlApp**: Main app entry point and menu bar setup

## Troubleshooting

### Bluetooth not working
- Ensure Bluetooth is enabled in System Settings
- Grant Bluetooth permission when prompted
- Check Console.app for error messages

### Volume control not working
- Ensure the app has necessary permissions
- Check that your output device supports volume control
- Some audio devices may not support programmatic volume control

### Connection issues
- Ensure mobile device Bluetooth is enabled
- Keep devices within Bluetooth range (typically 10 meters)
- Try restarting both applications

## Development Notes

The application uses:
- CoreBluetooth framework for BLE peripheral functionality
- CoreAudio framework for system volume control
- SwiftUI for the menu bar interface
- AudioObjectPropertyListener for real-time volume monitoring

## License

This project is part of the BLE Sound Volume Control system.
