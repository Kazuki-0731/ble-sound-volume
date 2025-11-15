import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// DeviceScanStateの基底クラス
sealed class DeviceScanState extends Equatable {
  const DeviceScanState();

  @override
  List<Object?> get props => [];
}

/// アイドル状態（スキャンしていない）
class ScanIdle extends DeviceScanState {
  const ScanIdle();
}

/// スキャン中状態
class ScanScanning extends DeviceScanState {
  const ScanScanning();
}

/// デバイスが見つかった状態
class ScanFound extends DeviceScanState {
  final List<BluetoothDevice> devices;

  const ScanFound({required this.devices});

  @override
  List<Object?> get props => [devices];
}

/// スキャンエラー状態
class ScanError extends DeviceScanState {
  final String message;

  const ScanError({required this.message});

  @override
  List<Object?> get props => [message];
}
