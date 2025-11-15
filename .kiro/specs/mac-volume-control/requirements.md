# Requirements Document

## Introduction

このシステムは、Android/iOSモバイルアプリケーションからBluetooth Low Energy (BLE)通信を使用してmacBookの音量を遠隔操作する機能を提供します。ユーザーはモバイルデバイス上のスライダーやボタンを使用して、接続されたmacBookのシステム音量をリアルタイムで調整できます。

## Glossary

- **Mobile App**: Android/iOSで動作するFlutterアプリケーション
- **macOS Host**: 音量制御を受け付けるmacBookデバイス
- **BLE Service**: Bluetooth Low Energy通信サービス
- **Volume Controller**: macOS上で音量制御を実行するコンポーネント
- **Connection Manager**: BLE接続の確立と管理を行うコンポーネント

## Requirements

### Requirement 1

**User Story:** モバイルアプリユーザーとして、近くにあるmacBookデバイスを発見して接続したい。そうすることで、音量制御を開始できるようになる。

#### Acceptance Criteria

1. WHEN Mobile App SHALL scan for available macOS Host devices within Bluetooth range
2. WHEN a macOS Host is discovered, THE Mobile App SHALL display the device name and connection status
3. WHEN the user selects a discovered device, THE Mobile App SHALL initiate a BLE connection to the macOS Host
4. IF the connection fails, THEN THE Mobile App SHALL display an error message and allow retry
5. WHEN a connection is established, THE Mobile App SHALL display a connected status indicator

### Requirement 2

**User Story:** モバイルアプリユーザーとして、接続されたmacBookの現在の音量レベルを確認したい。そうすることで、適切な音量調整ができる。

#### Acceptance Criteria

1. WHEN a BLE connection is established, THE Mobile App SHALL request the current volume level from the macOS Host
2. WHEN the macOS Host volume changes, THE macOS Host SHALL send the updated volume level to the Mobile App
3. THE Mobile App SHALL display the volume level as a percentage value between 0 and 100
4. THE Mobile App SHALL update the volume display within 500 milliseconds of receiving new data

### Requirement 3

**User Story:** モバイルアプリユーザーとして、スライダーを使ってmacBookの音量を調整したい。そうすることで、直感的に音量を変更できる。

#### Acceptance Criteria

1. WHILE connected to a macOS Host, THE Mobile App SHALL display an interactive volume slider
2. WHEN the user adjusts the slider, THE Mobile App SHALL send the new volume value to the macOS Host
3. THE macOS Host SHALL update the system volume to the received value within 200 milliseconds
4. THE Mobile App SHALL provide haptic feedback when the volume is adjusted
5. THE Volume Controller SHALL accept volume values between 0 and 100 percent

### Requirement 4

**User Story:** モバイルアプリユーザーとして、ミュート/ミュート解除ボタンを使いたい。そうすることで、素早く音を消したり戻したりできる。

#### Acceptance Criteria

1. WHILE connected to a macOS Host, THE Mobile App SHALL display a mute toggle button
2. WHEN the user taps the mute button, THE Mobile App SHALL send a mute command to the macOS Host
3. THE macOS Host SHALL mute or unmute the system volume based on the current state
4. THE Mobile App SHALL update the mute button icon to reflect the current mute state
5. WHEN the macOS Host is muted, THE macOS Host SHALL preserve the previous volume level for restoration

### Requirement 5

**User Story:** macOSホストユーザーとして、モバイルアプリからの接続を受け入れたい。そうすることで、音量制御を許可できる。

#### Acceptance Criteria

1. THE macOS Host SHALL advertise a BLE service for volume control
2. WHEN a Mobile App attempts to connect, THE macOS Host SHALL accept the connection request
3. THE macOS Host SHALL implement BLE characteristics for volume read, write, and notifications
4. THE macOS Host SHALL validate received volume values are within the range 0 to 100
5. IF an invalid volume value is received, THEN THE macOS Host SHALL ignore the command and log an error

### Requirement 6

**User Story:** ユーザーとして、接続が切断された場合に通知を受けたい。そうすることで、再接続が必要なことを知ることができる。

#### Acceptance Criteria

1. WHEN the BLE connection is lost, THE Mobile App SHALL display a disconnection notification
2. THE Mobile App SHALL automatically attempt to reconnect to the last connected macOS Host
3. THE Mobile App SHALL retry connection up to 3 times with 5 second intervals
4. IF reconnection fails after 3 attempts, THEN THE Mobile App SHALL return to the device discovery screen
5. THE Connection Manager SHALL clean up resources when a connection is terminated
