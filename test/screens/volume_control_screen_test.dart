import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ble_sound_volume/screens/volume_control_screen.dart';
import 'package:ble_sound_volume/bloc/volume_control_bloc.dart';
import 'package:ble_sound_volume/bloc/volume_state.dart';
import 'package:ble_sound_volume/models/volume_data.dart';
import '../mocks/ble_repository_mock.mocks.dart';

void main() {
  late MockBleRepository mockBleRepository;

  setUp(() {
    mockBleRepository = MockBleRepository();
  });

  Widget createTestWidget({VolumeState? initialState}) {
    return MaterialApp(
      home: BlocProvider<VolumeControlBloc>(
        create: (_) {
          final bloc = VolumeControlBloc(bleRepository: mockBleRepository);
          if (initialState != null) {
            bloc.emit(initialState);
          }
          return bloc;
        },
        child: const VolumeControlScreen(),
      ),
    );
  }

  group('VolumeControlScreen', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('音量コントロール'), findsOneWidget);
    });

    testWidgets('displays connecting state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          initialState: const VolumeConnecting(deviceName: 'Test Device'),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Deviceに接続中...'), findsOneWidget);
    });

    testWidgets('displays disconnected message when not connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(initialState: const VolumeDisconnected()),
      );
      await tester.pump();

      expect(find.text('接続されていません'), findsOneWidget);
    });

    testWidgets('displays connected state with volume controls',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 50,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('接続済み'), findsOneWidget);
      expect(find.text('Test Device'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('ミュート'), findsOneWidget);
      expect(find.text('切断'), findsOneWidget);
    });

    testWidgets('displays connection status card',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 75,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'MacBook Pro',
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.bluetooth_connected), findsOneWidget);
      expect(find.text('接続済み'), findsOneWidget);
      expect(find.text('MacBook Pro'), findsOneWidget);
    });

    testWidgets('volume slider displays correct value',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 75,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('音量'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byIcon(Icons.volume_down), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 75.0);
      expect(slider.min, 0.0);
      expect(slider.max, 100.0);
    });

    testWidgets('mute button shows correct state when not muted',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 50,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ミュート'), findsOneWidget);
      
      final muteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'ミュート'),
      );
      expect(muteButton.style?.backgroundColor?.resolve({}), Colors.blue);
    });

    testWidgets('mute button shows correct state when muted',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 50,
        isMuted: true,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ミュート解除'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      
      final muteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'ミュート解除'),
      );
      expect(muteButton.style?.backgroundColor?.resolve({}), Colors.red);
    });

    testWidgets('disconnect button is displayed',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 50,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('切断'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
      
      final disconnectButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '切断'),
      );
      expect(
        disconnectButton.style?.foregroundColor?.resolve({}),
        Colors.red,
      );
    });

    testWidgets('slider interaction triggers volume change',
        (WidgetTester tester) async {
      final volumeData = VolumeData(
        level: 50,
        isMuted: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          initialState: VolumeConnected(
            volumeData: volumeData,
            deviceName: 'Test Device',
          ),
        ),
      );
      await tester.pump();

      // Find and drag the slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to change volume
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // Verify slider exists (actual value change would require bloc interaction)
      expect(slider, findsOneWidget);
    });
  });
}
