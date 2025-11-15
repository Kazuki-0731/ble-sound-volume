import 'package:equatable/equatable.dart';
import 'package:ble_sound_volume/models/models.dart';

/// VolumeStateの基底クラス
sealed class VolumeState extends Equatable {
  const VolumeState();

  @override
  List<Object?> get props => [];
}

/// 切断状態
class VolumeDisconnected extends VolumeState {
  const VolumeDisconnected();
}

/// 接続中状態
class VolumeConnecting extends VolumeState {
  final String deviceName;

  const VolumeConnecting({required this.deviceName});

  @override
  List<Object?> get props => [deviceName];
}

/// 接続済み状態
class VolumeConnected extends VolumeState {
  final VolumeData volumeData;
  final String deviceName;

  const VolumeConnected({
    required this.volumeData,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [volumeData, deviceName];
}

/// エラー状態
class VolumeError extends VolumeState {
  final String message;

  const VolumeError({required this.message});

  @override
  List<Object?> get props => [message];
}
