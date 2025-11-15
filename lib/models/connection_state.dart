import 'package:equatable/equatable.dart';

/// ConnectionStateモデルクラス
/// BLE接続の状態を保持
class ConnectionState extends Equatable {
  /// 接続状態
  final bool isConnected;

  /// デバイス名
  final String? deviceName;

  /// デバイスID
  final String? deviceId;

  /// エラーメッセージ
  final String? errorMessage;

  const ConnectionState({
    required this.isConnected,
    this.deviceName,
    this.deviceId,
    this.errorMessage,
  });

  /// 切断状態のファクトリコンストラクタ
  const ConnectionState.disconnected()
      : isConnected = false,
        deviceName = null,
        deviceId = null,
        errorMessage = null;

  /// 接続状態のファクトリコンストラクタ
  const ConnectionState.connected({
    required String deviceName,
    required String deviceId,
  })  : isConnected = true,
        deviceName = deviceName,
        deviceId = deviceId,
        errorMessage = null;

  /// エラー状態のファクトリコンストラクタ
  const ConnectionState.error({
    required String errorMessage,
  })  : isConnected = false,
        deviceName = null,
        deviceId = null,
        errorMessage = errorMessage;

  /// コピーコンストラクタ
  ConnectionState copyWith({
    bool? isConnected,
    String? deviceName,
    String? deviceId,
    String? errorMessage,
  }) {
    return ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isConnected, deviceName, deviceId, errorMessage];

  @override
  String toString() {
    return 'ConnectionState(isConnected: $isConnected, deviceName: $deviceName, deviceId: $deviceId, errorMessage: $errorMessage)';
  }
}
