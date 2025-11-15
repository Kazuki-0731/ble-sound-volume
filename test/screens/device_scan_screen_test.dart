import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_sound_volume/screens/device_scan_screen.dart';
import 'package:ble_sound_volume/bloc/device_scan_bloc.dart';
import 'package:ble_sound_volume/bloc/device_scan_state.dart';
import 'package:ble_sound_volume/bloc/volume_control_bloc.dart';
import '../mocks/ble_repository_mock.mocks.dart';

void main() {
  late MockBleRepository mockBleRepository;

  setUp(() {
    mockBleRepository = MockBleRepository();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DeviceScanBloc>(
            create: (_) => DeviceScanBloc(bleRepository: mockBleRepository),
          ),
          BlocProvider<VolumeControlBloc>(
            create: (_) => VolumeControlBloc(bleRepository: mockBleRepository),
          ),
        ],
        child: const DeviceScanScreen(),
      ),
    );
  }

  group('DeviceScanScreen', () {
    testWidgets('displays title and scan button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('デバイスを検索'), findsOneWidget);
      expect(find.text('スキャン開始'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays idle message when not scanning',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('スキャンボタンを押してデバイスを検索してください'),
        findsOneWidget,
      );
    });



    testWidgets('displays device list when devices are found',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Access the bloc from context
      final context = tester.element(find.byType(DeviceScanScreen));
      final deviceScanBloc = BlocProvider.of<DeviceScanBloc>(context);

      final testDevice = BluetoothDevice.fromId('test-device-id');
      deviceScanBloc.emit(ScanFound(devices: [testDevice]));

      await tester.pump();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays empty message when no devices found after scanning',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final context = tester.element(find.byType(DeviceScanScreen));
      final deviceScanBloc = BlocProvider.of<DeviceScanBloc>(context);

      deviceScanBloc.emit(const ScanFound(devices: []));

      await tester.pump();

      expect(find.text('デバイスが見つかりませんでした'), findsOneWidget);
    });

    testWidgets('scan button exists and is tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final scanButton = find.text('スキャン開始');
      expect(scanButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(scanButton);
      await tester.pump();
    });
  });
}
