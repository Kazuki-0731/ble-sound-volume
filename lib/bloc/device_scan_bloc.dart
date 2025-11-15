import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_sound_volume/bloc/device_scan_event.dart';
import 'package:ble_sound_volume/bloc/device_scan_state.dart';
import 'package:ble_sound_volume/repositories/repositories.dart';

/// DeviceScanBloc
/// BLEデバイスのスキャンを管理するBLoC
class DeviceScanBloc extends Bloc<DeviceScanEvent, DeviceScanState> {
  final BleRepository _bleRepository;
  StreamSubscription<List<BluetoothDevice>>? _scanSubscription;
  final List<BluetoothDevice> _discoveredDevices = [];

  DeviceScanBloc({
    required BleRepository bleRepository,
  })  : _bleRepository = bleRepository,
        super(const ScanIdle()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<DeviceFound>(_onDeviceFound);
  }

  /// スキャンを開始するイベントハンドラ
  Future<void> _onStartScan(
    StartScan event,
    Emitter<DeviceScanState> emit,
  ) async {
    try {
      // 既存のデバイスリストをクリア
      _discoveredDevices.clear();

      emit(const ScanScanning());

      // デバイススキャンを開始
      _scanSubscription = _bleRepository.scanForDevices().listen(
        (devices) {
          // 新しいデバイスを追加
          for (final device in devices) {
            if (!_discoveredDevices.any((d) => d.remoteId == device.remoteId)) {
              _discoveredDevices.add(device);
            }
          }

          // 状態を更新
          add(DeviceFound(device: devices.isNotEmpty ? devices.first : _discoveredDevices.first));
        },
        onError: (error) {
          emit(ScanError(message: 'スキャンエラー: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(ScanError(message: 'スキャン開始に失敗しました: ${e.toString()}'));
    }
  }

  /// スキャンを停止するイベントハンドラ
  Future<void> _onStopScan(
    StopScan event,
    Emitter<DeviceScanState> emit,
  ) async {
    try {
      // スキャンを停止
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      // 発見されたデバイスがある場合はScanFound状態に、なければScanIdle状態に
      if (_discoveredDevices.isNotEmpty) {
        emit(ScanFound(devices: List.from(_discoveredDevices)));
      } else {
        emit(const ScanIdle());
      }
    } catch (e) {
      emit(ScanError(message: 'スキャン停止に失敗しました: ${e.toString()}'));
    }
  }

  /// デバイスが見つかったイベントハンドラ
  Future<void> _onDeviceFound(
    DeviceFound event,
    Emitter<DeviceScanState> emit,
  ) async {
    // 現在のデバイスリストを発行
    emit(ScanFound(devices: List.from(_discoveredDevices)));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
