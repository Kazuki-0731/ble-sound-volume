import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ble_sound_volume/bloc/bloc.dart';
import 'package:ble_sound_volume/repositories/repositories.dart';
import 'package:ble_sound_volume/screens/device_scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BleRepositoryのインスタンスを作成
    final bleRepository = BleRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        // DeviceScanBlocを提供
        BlocProvider<DeviceScanBloc>(
          create: (context) => DeviceScanBloc(
            bleRepository: bleRepository,
          ),
        ),
        // VolumeControlBlocを提供
        BlocProvider<VolumeControlBloc>(
          create: (context) => VolumeControlBloc(
            bleRepository: bleRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BLE Volume Control',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DeviceScanScreen(),
      ),
    );
  }
}
