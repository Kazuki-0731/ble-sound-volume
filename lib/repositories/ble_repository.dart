import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLEリポジトリのインターフェース
/// macOS Hostとの通信を抽象化
abstract class BleRepository {
  /// デバイスをスキャンする
  /// 発見されたデバイスのストリームを返す
  Stream<List<BluetoothDevice>> scanForDevices();

  /// 指定されたデバイスに接続する
  /// [device] 接続するBluetoothデバイス
  /// 接続に失敗した場合は例外をスロー
  Future<void> connect(BluetoothDevice device);

  /// 現在接続されているデバイスから切断する
  Future<void> disconnect();

  /// 音量変更のストリーム
  /// デバイスからの音量通知を受信
  Stream<int> get volumeStream;

  /// 音量を設定する
  /// [volume] 設定する音量レベル (0-100)
  Future<void> setVolume(int volume);

  /// ミュート状態をトグルする
  Future<void> toggleMute();

  /// 現在の音量を取得する
  /// 現在の音量レベル (0-100) を返す
  Future<int> getCurrentVolume();
}
