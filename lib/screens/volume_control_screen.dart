import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ble_sound_volume/bloc/bloc.dart';

/// VolumeControlScreen
/// 接続されたデバイスの音量を制御する画面
class VolumeControlScreen extends StatelessWidget {
  const VolumeControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音量コントロール'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<VolumeControlBloc, VolumeState>(
        listener: (context, state) {
          // エラー時にスナックバーを表示
          if (state is VolumeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          // 切断時に前の画面に戻る
          if (state is VolumeDisconnected) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is VolumeConnecting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('${state.deviceName}に接続中...'),
                ],
              ),
            );
          }

          if (state is VolumeConnected) {
            return _buildConnectedView(context, state);
          }

          return const Center(
            child: Text('接続されていません'),
          );
        },
      ),
    );
  }

  /// 接続済みビューを構築
  Widget _buildConnectedView(BuildContext context, VolumeConnected state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 接続状態表示
          _buildConnectionStatus(state),
          const SizedBox(height: 48),
          // 音量スライダー
          _buildVolumeSlider(context, state),
          const SizedBox(height: 48),
          // ミュートボタン
          _buildMuteButton(context, state),
          const SizedBox(height: 24),
          // 切断ボタン
          _buildDisconnectButton(context),
        ],
      ),
    );
  }

  /// 接続状態表示ウィジェット
  Widget _buildConnectionStatus(VolumeConnected state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.bluetooth_connected,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              '接続済み',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.deviceName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 音量スライダーウィジェット
  Widget _buildVolumeSlider(BuildContext context, VolumeConnected state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '音量',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${state.volumeData.level}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.volume_down),
            Expanded(
              child: Slider(
                value: state.volumeData.level.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '${state.volumeData.level}%',
                onChanged: (value) {
                  // ハプティックフィードバックを提供
                  HapticFeedback.selectionClick();
                  
                  context.read<VolumeControlBloc>().add(
                        SetVolumeLevel(level: value.toInt()),
                      );
                },
              ),
            ),
            const Icon(Icons.volume_up),
          ],
        ),
      ],
    );
  }

  /// ミュートボタンウィジェット
  Widget _buildMuteButton(BuildContext context, VolumeConnected state) {
    final isMuted = state.volumeData.isMuted;

    return ElevatedButton.icon(
      onPressed: () {
        context.read<VolumeControlBloc>().add(const ToggleMuteState());
      },
      icon: Icon(
        isMuted ? Icons.volume_off : Icons.volume_up,
        size: 32,
      ),
      label: Text(
        isMuted ? 'ミュート解除' : 'ミュート',
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 64),
        backgroundColor: isMuted ? Colors.red : Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 切断ボタンウィジェット
  Widget _buildDisconnectButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<VolumeControlBloc>().add(const DisconnectFromDevice());
      },
      icon: const Icon(Icons.bluetooth_disabled),
      label: const Text('切断'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
    );
  }
}
