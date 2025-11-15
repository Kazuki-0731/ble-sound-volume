import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_sound_volume/bloc/volume_control_bloc.dart';
import 'package:ble_sound_volume/bloc/volume_event.dart';
import 'package:ble_sound_volume/bloc/volume_state.dart';
import 'package:ble_sound_volume/models/volume_data.dart';
import '../mocks/ble_repository_mock.mocks.dart';

void main() {
  late MockBleRepository mockBleRepository;
  late StreamController<int> volumeStreamController;

  setUp(() {
    mockBleRepository = MockBleRepository();
    volumeStreamController = StreamController<int>.broadcast();
    
    // Setup default mock behavior
    when(mockBleRepository.volumeStream)
        .thenAnswer((_) => volumeStreamController.stream);
  });

  tearDown(() {
    volumeStreamController.close();
  });

  group('VolumeControlBloc', () {
    test('initial state is VolumeDisconnected', () {
      final bloc = VolumeControlBloc(bleRepository: mockBleRepository);
      expect(bloc.state, equals(const VolumeDisconnected()));
      bloc.close();
    });

    group('ConnectToDevice', () {
      blocTest<VolumeControlBloc, VolumeState>(
        'emits [VolumeConnecting, VolumeConnected] when connection succeeds',
        build: () {
          when(mockBleRepository.connect(any))
              .thenAnswer((_) async => Future.value());
          when(mockBleRepository.getCurrentVolume())
              .thenAnswer((_) async => 50);
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        act: (bloc) {
          final device = BluetoothDevice.fromId('test-device-id');
          bloc.add(ConnectToDevice(device: device));
        },
        expect: () => [
          isA<VolumeConnecting>(),
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 50),
        ],
        verify: (_) {
          verify(mockBleRepository.connect(any)).called(1);
          verify(mockBleRepository.getCurrentVolume()).called(1);
        },
      );

      blocTest<VolumeControlBloc, VolumeState>(
        'emits [VolumeConnecting, VolumeError] when connection fails',
        build: () {
          when(mockBleRepository.connect(any))
              .thenThrow(Exception('Connection failed'));
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        act: (bloc) {
          final device = BluetoothDevice.fromId('test-device-id');
          bloc.add(ConnectToDevice(device: device));
        },
        expect: () => [
          isA<VolumeConnecting>(),
          isA<VolumeError>()
              .having((s) => s.message, 'error message', contains('接続に失敗')),
        ],
      );


    });

    group('DisconnectFromDevice', () {
      blocTest<VolumeControlBloc, VolumeState>(
        'emits [VolumeDisconnected] when disconnect succeeds',
        build: () {
          when(mockBleRepository.disconnect())
              .thenAnswer((_) async => Future.value());
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        act: (bloc) => bloc.add(const DisconnectFromDevice()),
        expect: () => [
          isA<VolumeDisconnected>(),
        ],
        verify: (_) {
          verify(mockBleRepository.disconnect()).called(1);
        },
      );

      blocTest<VolumeControlBloc, VolumeState>(
        'emits [VolumeError] when disconnect fails',
        build: () {
          when(mockBleRepository.disconnect())
              .thenThrow(Exception('Disconnect failed'));
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        act: (bloc) => bloc.add(const DisconnectFromDevice()),
        expect: () => [
          isA<VolumeError>()
              .having((s) => s.message, 'error message', contains('切断に失敗')),
        ],
      );
    });

    group('SetVolumeLevel', () {
      blocTest<VolumeControlBloc, VolumeState>(
        'updates volume level and calls setVolume after debounce',
        build: () {
          when(mockBleRepository.connect(any))
              .thenAnswer((_) async => Future.value());
          when(mockBleRepository.getCurrentVolume())
              .thenAnswer((_) async => 50);
          when(mockBleRepository.setVolume(any))
              .thenAnswer((_) async => Future.value());
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) async {
          bloc.add(const SetVolumeLevel(level: 75));
          // Wait for debounce timer (100ms)
          await Future.delayed(const Duration(milliseconds: 150));
        },
        expect: () => [
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 75),
        ],
        verify: (_) {
          verify(mockBleRepository.setVolume(75)).called(1);
        },
      );

      blocTest<VolumeControlBloc, VolumeState>(
        'clamps volume level to 0-100 range',
        build: () {
          when(mockBleRepository.setVolume(any))
              .thenAnswer((_) async => Future.value());
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) async {
          bloc.add(const SetVolumeLevel(level: 150));
          await Future.delayed(const Duration(milliseconds: 150));
        },
        expect: () => [
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 100),
        ],
      );

      blocTest<VolumeControlBloc, VolumeState>(
        'debounces multiple rapid volume changes',
        build: () {
          when(mockBleRepository.setVolume(any))
              .thenAnswer((_) async => Future.value());
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) async {
          bloc.add(const SetVolumeLevel(level: 60));
          await Future.delayed(const Duration(milliseconds: 20));
          bloc.add(const SetVolumeLevel(level: 70));
          await Future.delayed(const Duration(milliseconds: 20));
          bloc.add(const SetVolumeLevel(level: 80));
          await Future.delayed(const Duration(milliseconds: 150));
        },
        expect: () => [
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 60),
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 70),
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 80),
        ],
        verify: (_) {
          // Only the last value should be sent to the device
          verify(mockBleRepository.setVolume(80)).called(1);
          verifyNever(mockBleRepository.setVolume(60));
          verifyNever(mockBleRepository.setVolume(70));
        },
      );
    });

    group('ToggleMuteState', () {
      blocTest<VolumeControlBloc, VolumeState>(
        'toggles mute state when connected',
        build: () {
          when(mockBleRepository.toggleMute())
              .thenAnswer((_) async => Future.value());
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) => bloc.add(const ToggleMuteState()),
        expect: () => [
          isA<VolumeConnected>()
              .having((s) => s.volumeData.isMuted, 'is muted', true),
        ],
        verify: (_) {
          verify(mockBleRepository.toggleMute()).called(1);
        },
      );

      blocTest<VolumeControlBloc, VolumeState>(
        'emits error when toggle mute fails',
        build: () {
          when(mockBleRepository.toggleMute())
              .thenThrow(Exception('Toggle mute failed'));
          return VolumeControlBloc(bleRepository: mockBleRepository);
        },
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) => bloc.add(const ToggleMuteState()),
        expect: () => [
          isA<VolumeError>().having(
              (s) => s.message, 'error message', contains('ミュート切り替えに失敗')),
        ],
      );
    });

    group('VolumeUpdatedFromDevice', () {
      blocTest<VolumeControlBloc, VolumeState>(
        'updates volume when device sends notification',
        build: () => VolumeControlBloc(bleRepository: mockBleRepository),
        seed: () => VolumeConnected(
          volumeData: VolumeData(
            level: 50,
            isMuted: false,
            timestamp: DateTime.now(),
          ),
          deviceName: 'Test Device',
        ),
        act: (bloc) {
          final newVolumeData = VolumeData(
            level: 75,
            isMuted: false,
            timestamp: DateTime.now(),
          );
          bloc.add(VolumeUpdatedFromDevice(data: newVolumeData));
        },
        expect: () => [
          isA<VolumeConnected>()
              .having((s) => s.volumeData.level, 'volume level', 75),
        ],
      );
    });
  });
}
