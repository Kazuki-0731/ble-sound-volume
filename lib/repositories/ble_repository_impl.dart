import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_repository.dart';

/// BleRepositoryの実装クラス
/// flutter_blue_plusを使用してBLE通信を実装
class BleRepositoryImpl implements BleRepository {
  // カスタムサービスとキャラクタリスティックのUUID
  static const String _serviceUuid = '12345678-1234-1234-1234-123456789ABC';
  static const String _volumeCharacteristicUuid =
      '12345678-1234-1234-1234-123456789ABD';
  static const String _muteCharacteristicUuid =
      '12345678-1234-1234-1234-123456789ABE';

  // 再接続設定
  static const int _maxReconnectAttempts = 3;
  static const Duration _reconnectInterval = Duration(seconds: 5);

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _volumeCharacteristic;
  BluetoothCharacteristic? _muteCharacteristic;

  final StreamController<int> _volumeStreamController =
      StreamController<int>.broadcast();

  StreamSubscription<List<int>>? _volumeSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  bool _shouldReconnect = true;

  @override
  Stream<List<BluetoothDevice>> scanForDevices() {
    // スキャン結果のストリームコントローラー
    final controller = StreamController<List<BluetoothDevice>>();
    final discoveredDevices = <String, BluetoothDevice>{};

    // スキャンを開始
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      withServices: [Guid(_serviceUuid)],
    );

    // スキャン結果を監視
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        discoveredDevices[result.device.remoteId.toString()] = result.device;
      }
      controller.add(discoveredDevices.values.toList());
    });

    // スキャン完了時にクリーンアップ
    controller.onCancel = () {
      subscription.cancel();
      FlutterBluePlus.stopScan();
    };

    return controller.stream;
  }

  @override
  Future<void> connect(BluetoothDevice device) async {
    try {
      _connectedDevice = device;
      _shouldReconnect = true;
      _reconnectAttempts = 0;

      // デバイスに接続（10秒タイムアウト）
      await device.connect(timeout: const Duration(seconds: 10)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection to device timed out');
        },
      );

      // 接続状態の監視を開始
      _setupConnectionStateListener();

      // サービスを検索（5秒タイムアウト）
      final services = await device.discoverServices().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Service discovery timed out');
        },
      );

      // 音量制御サービスを見つける
      final volumeService = services.firstWhere(
        (service) => service.uuid.toString().toLowerCase() ==
            _serviceUuid.toLowerCase(),
        orElse: () => throw Exception('Volume control service not found'),
      );

      // 音量キャラクタリスティックを見つける
      _volumeCharacteristic = volumeService.characteristics.firstWhere(
        (char) => char.uuid.toString().toLowerCase() ==
            _volumeCharacteristicUuid.toLowerCase(),
        orElse: () => throw Exception('Volume characteristic not found'),
      );

      // ミュートキャラクタリスティックを見つける
      _muteCharacteristic = volumeService.characteristics.firstWhere(
        (char) => char.uuid.toString().toLowerCase() ==
            _muteCharacteristicUuid.toLowerCase(),
        orElse: () => throw Exception('Mute characteristic not found'),
      );

      // 音量通知を購読
      await _volumeCharacteristic!.setNotifyValue(true).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Failed to enable volume notifications');
        },
      );
      
      _volumeSubscription =
          _volumeCharacteristic!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final volumeLevel = value[0];
          _volumeStreamController.add(volumeLevel);
        }
      });

      // 接続成功時は再接続カウンターをリセット
      _reconnectAttempts = 0;
    } catch (e) {
      _connectedDevice = null;
      _volumeCharacteristic = null;
      _muteCharacteristic = null;
      throw Exception('Failed to connect to device: $e');
    }
  }

  /// 接続状態の監視を設定
  void _setupConnectionStateListener() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription =
        _connectedDevice?.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _handleDisconnection();
      }
    });
  }

  /// 切断時の処理
  void _handleDisconnection() async {
    // 既に再接続中の場合は何もしない
    if (_isReconnecting || !_shouldReconnect) {
      return;
    }

    // 再接続を試みる
    if (_reconnectAttempts < _maxReconnectAttempts && _connectedDevice != null) {
      _isReconnecting = true;
      _reconnectAttempts++;

      try {
        // 指定された間隔待機
        await Future.delayed(_reconnectInterval);

        // 再接続を試みる
        await connect(_connectedDevice!);
        _isReconnecting = false;
      } catch (e) {
        _isReconnecting = false;
        // 再接続に失敗した場合、再度試みる（最大回数まで）
        _handleDisconnection();
      }
    } else {
      // 最大再接続回数に達した場合、リソースをクリーンアップ
      await _cleanupResources();
    }
  }

  @override
  Future<void> disconnect() async {
    // 再接続を無効化
    _shouldReconnect = false;

    try {
      // デバイスから切断
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
    } finally {
      await _cleanupResources();
    }
  }

  /// リソースのクリーンアップ
  Future<void> _cleanupResources() async {
    // 通知購読を解除
    await _volumeSubscription?.cancel();
    _volumeSubscription = null;

    // 接続状態の監視を解除
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    _connectedDevice = null;
    _volumeCharacteristic = null;
    _muteCharacteristic = null;
    _reconnectAttempts = 0;
    _isReconnecting = false;
  }

  @override
  Stream<int> get volumeStream => _volumeStreamController.stream;

  @override
  Future<void> setVolume(int volume) async {
    if (_volumeCharacteristic == null) {
      throw Exception('Not connected to device');
    }

    // 音量値を0-100の範囲にクランプ
    final clampedVolume = volume.clamp(0, 100);

    try {
      // 音量値を書き込み（3秒タイムアウト）
      await _volumeCharacteristic!.write(
        [clampedVolume],
        timeout: 3,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Volume write operation timed out');
        },
      );
    } catch (e) {
      throw Exception('Failed to set volume: $e');
    }
  }

  @override
  Future<void> toggleMute() async {
    if (_muteCharacteristic == null) {
      throw Exception('Not connected to device');
    }

    try {
      // 現在のミュート状態を読み取り（2秒タイムアウト）
      final currentValue = await _muteCharacteristic!.read(timeout: 2).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Mute state read operation timed out');
        },
      );
      final currentMuteState = currentValue.isNotEmpty ? currentValue[0] : 0;

      // ミュート状態をトグル (0 -> 1, 1 -> 0)
      final newMuteState = currentMuteState == 0 ? 1 : 0;

      // 新しいミュート状態を書き込み（3秒タイムアウト）
      await _muteCharacteristic!.write(
        [newMuteState],
        timeout: 3,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Mute state write operation timed out');
        },
      );
    } catch (e) {
      throw Exception('Failed to toggle mute: $e');
    }
  }

  @override
  Future<int> getCurrentVolume() async {
    if (_volumeCharacteristic == null) {
      throw Exception('Not connected to device');
    }

    try {
      // 音量値を読み取り（2秒タイムアウト）
      final value = await _volumeCharacteristic!.read(timeout: 2).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Volume read operation timed out');
        },
      );

      if (value.isEmpty) {
        throw Exception('Failed to read volume: empty response');
      }

      return value[0];
    } catch (e) {
      throw Exception('Failed to get current volume: $e');
    }
  }

  /// リソースをクリーンアップ
  void dispose() {
    _volumeSubscription?.cancel();
    _volumeStreamController.close();
  }
}
