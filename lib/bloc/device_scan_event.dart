import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// DeviceScanEventの基底クラス
sealed class DeviceScanEvent extends Equatable {
  const DeviceScanEvent();

  @override
  List<Object?> get props => [];
}

/// スキャンを開始するイベント
class StartScan extends DeviceScanEvent {
  const StartScan();
}

/// スキャンを停止するイベント
class StopScan extends DeviceScanEvent {
  const StopScan();
}

/// デバイスが見つかったイベント
class DeviceFound extends DeviceScanEvent {
  final BluetoothDevice device;

  const DeviceFound({required this.device});

  @override
  List<Object?> get props => [device];
}
