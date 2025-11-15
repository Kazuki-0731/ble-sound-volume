import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ble_sound_volume/bloc/bloc.dart';
import 'package:ble_sound_volume/screens/volume_control_screen.dart';

/// DeviceScanScreen
/// BLEデバイスをスキャンして接続するための画面
class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  @override
  void initState() {
    super.initState();
    _checkBluetoothPermissions();
  }

  /// Bluetooth権限をチェックしてリクエスト
  Future<void> _checkBluetoothPermissions() async {
    // Bluetooth権限をチェック
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;

    // 権限がない場合はリクエスト
    if (!bluetoothScan.isGranted || !bluetoothConnect.isGranted) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      // 権限が拒否された場合
      if (results[Permission.bluetoothScan]!.isDenied ||
          results[Permission.bluetoothConnect]!.isDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    }
  }

  /// 権限拒否ダイアログを表示
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth権限が必要です'),
        content: const Text(
          'この機能を使用するにはBluetooth権限が必要です。設定から権限を許可してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  /// スキャンを開始
  void _startScan() {
    context.read<DeviceScanBloc>().add(const StartScan());
  }

  /// スキャンを停止
  void _stopScan() {
    context.read<DeviceScanBloc>().add(const StopScan());
  }

  /// デバイスに接続
  void _connectToDevice(BluetoothDevice device) {
    // スキャンを停止
    _stopScan();

    // 接続イベントを発行
    context.read<VolumeControlBloc>().add(ConnectToDevice(device: device));

    // VolumeControlScreenに遷移
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VolumeControlScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('デバイスを検索'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<DeviceScanBloc, DeviceScanState>(
        listener: (context, state) {
          // エラー時にスナックバーを表示
          if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // スキャンボタンとステータス
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (state is ScanScanning)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('デバイスをスキャン中...'),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(Icons.search),
                        label: const Text('スキャン開始'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    if (state is ScanScanning) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _stopScan,
                        child: const Text('スキャン停止'),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(),
              // デバイスリスト
              Expanded(
                child: _buildDeviceList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  /// デバイスリストを構築
  Widget _buildDeviceList(DeviceScanState state) {
    if (state is ScanIdle) {
      return const Center(
        child: Text('スキャンボタンを押してデバイスを検索してください'),
      );
    }

    if (state is ScanScanning || state is ScanFound) {
      final devices = state is ScanFound ? state.devices : <BluetoothDevice>[];

      if (devices.isEmpty && state is ScanScanning) {
        return const Center(
          child: Text('デバイスを検索中...'),
        );
      }

      if (devices.isEmpty) {
        return const Center(
          child: Text('デバイスが見つかりませんでした'),
        );
      }

      return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final deviceName = device.platformName.isNotEmpty
              ? device.platformName
              : '名前なし';

          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(deviceName),
            subtitle: Text(device.remoteId.toString()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _connectToDevice(device),
          );
        },
      );
    }

    return const Center(
      child: Text('エラーが発生しました'),
    );
  }
}
