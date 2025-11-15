import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ble_sound_volume/bloc/volume_event.dart';
import 'package:ble_sound_volume/bloc/volume_state.dart';
import 'package:ble_sound_volume/models/models.dart';
import 'package:ble_sound_volume/repositories/repositories.dart';

/// VolumeControlBloc
/// 音量制御の状態管理を行うBLoC
class VolumeControlBloc extends Bloc<VolumeEvent, VolumeState> {
  final BleRepository _bleRepository;
  StreamSubscription<int>? _volumeSubscription;
  Timer? _debounceTimer;
  int? _pendingVolumeLevel;

  VolumeControlBloc({
    required BleRepository bleRepository,
  })  : _bleRepository = bleRepository,
        super(const VolumeDisconnected()) {
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<SetVolumeLevel>(_onSetVolumeLevel);
    on<ToggleMuteState>(_onToggleMuteState);
    on<VolumeUpdatedFromDevice>(_onVolumeUpdatedFromDevice);
  }

  /// デバイスに接続するイベントハンドラ
  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<VolumeState> emit,
  ) async {
    try {
      emit(VolumeConnecting(deviceName: event.device.platformName));

      // デバイスに接続
      await _bleRepository.connect(event.device).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('接続がタイムアウトしました');
        },
      );

      // 現在の音量を取得
      final currentVolume = await _bleRepository.getCurrentVolume().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('音量の取得がタイムアウトしました');
        },
      );

      // 音量データを作成
      final volumeData = VolumeData(
        level: currentVolume,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      emit(VolumeConnected(
        volumeData: volumeData,
        deviceName: event.device.platformName,
      ));

      // 音量変更の監視を開始
      _volumeSubscription = _bleRepository.volumeStream.listen(
        (volume) {
          add(VolumeUpdatedFromDevice(
            data: VolumeData(
              level: volume,
              isMuted: false,
              timestamp: DateTime.now(),
            ),
          ));
        },
        onError: (error) {
          add(DisconnectFromDevice());
        },
      );
    } on TimeoutException catch (e) {
      emit(VolumeError(message: e.message ?? '接続がタイムアウトしました'));
    } catch (e) {
      emit(VolumeError(message: '接続に失敗しました: ${e.toString()}'));
    }
  }

  /// デバイスから切断するイベントハンドラ
  Future<void> _onDisconnectFromDevice(
    DisconnectFromDevice event,
    Emitter<VolumeState> emit,
  ) async {
    try {
      // 音量監視を停止
      await _volumeSubscription?.cancel();
      _volumeSubscription = null;

      // デバウンスタイマーをキャンセル
      _debounceTimer?.cancel();
      _debounceTimer = null;

      // デバイスから切断
      await _bleRepository.disconnect();

      emit(const VolumeDisconnected());
    } catch (e) {
      emit(VolumeError(message: '切断に失敗しました: ${e.toString()}'));
    }
  }

  /// 音量レベルを設定するイベントハンドラ（デバウンス処理付き）
  Future<void> _onSetVolumeLevel(
    SetVolumeLevel event,
    Emitter<VolumeState> emit,
  ) async {
    if (state is! VolumeConnected) return;

    // 音量値を0-100の範囲にクランプ
    final clampedVolume = event.level.clamp(0, 100);

    // UIを即座に更新
    final currentState = state as VolumeConnected;
    emit(VolumeConnected(
      volumeData: currentState.volumeData.copyWith(
        level: clampedVolume,
        timestamp: DateTime.now(),
      ),
      deviceName: currentState.deviceName,
    ));

    // デバウンスタイマーをキャンセル
    _debounceTimer?.cancel();

    // 保留中の音量レベルを保存
    _pendingVolumeLevel = clampedVolume;

    // 100ms後に実際の音量設定を実行
    _debounceTimer = Timer(const Duration(milliseconds: 100), () async {
      if (_pendingVolumeLevel == null) return;

      try {
        // 音量を設定
        await _bleRepository.setVolume(_pendingVolumeLevel!).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('音量設定がタイムアウトしました');
          },
        );

        _pendingVolumeLevel = null;
      } on TimeoutException {
        add(const DisconnectFromDevice());
      } catch (_) {
        add(const DisconnectFromDevice());
      }
    });
  }

  /// ミュート状態をトグルするイベントハンドラ
  Future<void> _onToggleMuteState(
    ToggleMuteState event,
    Emitter<VolumeState> emit,
  ) async {
    if (state is! VolumeConnected) return;

    try {
      // ミュート状態をトグル
      await _bleRepository.toggleMute().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('ミュート切り替えがタイムアウトしました');
        },
      );

      // 状態を更新
      final currentState = state as VolumeConnected;
      emit(VolumeConnected(
        volumeData: currentState.volumeData.copyWith(
          isMuted: !currentState.volumeData.isMuted,
          timestamp: DateTime.now(),
        ),
        deviceName: currentState.deviceName,
      ));
    } on TimeoutException catch (e) {
      emit(VolumeError(message: e.message ?? 'ミュート切り替えがタイムアウトしました'));
    } catch (e) {
      emit(VolumeError(message: 'ミュート切り替えに失敗しました: ${e.toString()}'));
    }
  }

  /// デバイスから音量が更新されたイベントハンドラ
  Future<void> _onVolumeUpdatedFromDevice(
    VolumeUpdatedFromDevice event,
    Emitter<VolumeState> emit,
  ) async {
    if (state is! VolumeConnected) return;

    final currentState = state as VolumeConnected;
    emit(VolumeConnected(
      volumeData: event.data,
      deviceName: currentState.deviceName,
    ));
  }

  @override
  Future<void> close() {
    _volumeSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
