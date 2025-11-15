import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_sound_volume/models/models.dart';

/// VolumeEventの基底クラス
sealed class VolumeEvent extends Equatable {
  const VolumeEvent();

  @override
  List<Object?> get props => [];
}

/// デバイスに接続するイベント
class ConnectToDevice extends VolumeEvent {
  final BluetoothDevice device;

  const ConnectToDevice({required this.device});

  @override
  List<Object?> get props => [device];
}

/// デバイスから切断するイベント
class DisconnectFromDevice extends VolumeEvent {
  const DisconnectFromDevice();
}

/// 音量レベルを設定するイベント
class SetVolumeLevel extends VolumeEvent {
  final int level;

  const SetVolumeLevel({required this.level});

  @override
  List<Object?> get props => [level];
}

/// ミュート状態をトグルするイベント
class ToggleMuteState extends VolumeEvent {
  const ToggleMuteState();
}

/// デバイスから音量が更新されたイベント
class VolumeUpdatedFromDevice extends VolumeEvent {
  final VolumeData data;

  const VolumeUpdatedFromDevice({required this.data});

  @override
  List<Object?> get props => [data];
}
