# BLE Sound Volume

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4CAF50?style=flat)](https://flutter.dev)
[![macOS](https://img.shields.io/badge/macOS-13.0+-9B59B6?style=flat&logo=apple)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.0+-FA7343?style=flat&logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)](LICENSE)
[![BLE](https://img.shields.io/badge/BLE-4.0+-1E90FF?style=flat&logo=bluetooth)](https://www.bluetooth.com)

A Flutter application for remotely controlling macOS volume via Bluetooth Low Energy (BLE) communication.

**[日本語版 README はこちら](README.ja.md)**

## Overview

This system allows you to control macBook's system volume in real-time from Android/iOS mobile applications using BLE communication. Users can intuitively adjust the volume of their connected macBook using sliders and buttons on their mobile devices.

## Key Features

- 🔍 **Device Scanning**: Discover and search for macOS devices within Bluetooth range
- 🔗 **BLE Connection**: Connect to discovered devices with automatic reconnection
- 🎚️ **Volume Control**: Intuitive volume adjustment using a slider (0-100%)
- 🔇 **Mute Function**: One-tap mute/unmute
- 📊 **Real-time Sync**: Automatically reflect macOS volume changes in the mobile app
- 📳 **Haptic Feedback**: Tactile feedback during volume adjustment
- 🔄 **Auto Reconnection**: Automatic reconnection on disconnect (up to 3 times, 5-second intervals)

## Architecture

### System Configuration

```
┌─────────────────────────────┐         ┌─────────────────────────────┐
│    Mobile App (Flutter)     │         │      macOS Host (Swift)     │
│                             │         │                             │
│  ┌───────────────────────┐ │         │  ┌───────────────────────┐ │
│  │    UI Layer           │ │         │  │   BLE Service         │ │
│  │  - DeviceScanScreen   │ │         │  │   (Peripheral)        │ │
│  │  - VolumeControlScreen│ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │             │              │
│             │               │   BLE   │             │              │
│  ┌───────────────────────┐ │◄───────►│  ┌───────────────────────┐ │
│  │   BLoC Layer          │ │  GATT   │  │  Volume Controller    │ │
│  │  - VolumeControlBloc  │ │         │  │  (CoreAudio)          │ │
│  │  - DeviceScanBloc     │ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │             │              │
│             │               │         │             ▼              │
│  ┌───────────────────────┐ │         │  ┌───────────────────────┐ │
│  │  Repository Layer     │ │         │  │   macOS Audio System  │ │
│  │  - BleRepositoryImpl  │ │         │  └───────────────────────┘ │
│  └───────────────────────┘ │         │                             │
└─────────────────────────────┘         └─────────────────────────────┘
```

### BLE GATT Profile

**Service UUID**: `12345678-1234-1234-1234-123456789ABC`

**Characteristics**:
- **Volume Level** (`12345678-1234-1234-1234-123456789ABD`)
  - Type: UInt8 (0-100)
  - Properties: Read, Write, Notify

- **Mute State** (`12345678-1234-1234-1234-123456789ABE`)
  - Type: UInt8 (0=unmuted, 1=muted)
  - Properties: Read, Write, Notify

## Tech Stack

### Mobile App (Flutter)

- **Flutter** - Cross-platform UI framework
- **flutter_blue_plus** (^1.32.0) - BLE communication
- **flutter_bloc** (^8.1.0) - State management
- **equatable** (^2.0.0) - Value comparison
- **permission_handler** (^11.0.0) - Permission management

### macOS Host (Swift)

- **CoreBluetooth** - BLE implementation
- **CoreAudio** - System volume control
- **SwiftUI** - Menu bar app UI

## Setup

### Prerequisites

- Flutter SDK 3.0 or higher
- Xcode 15.0 or higher (for building macOS app)
- Android Studio / VS Code
- macOS 13.0 or higher (for running host app)

### Mobile App Setup

1. Clone the repository
```bash
git clone https://github.com/Kazuki-0731/ble-sound-volume.git
cd ble-sound-volume
```

2. Install dependencies
```bash
flutter pub get
```

3. Install CocoaPods for iOS
```bash
cd ios
pod install
cd ..
```

4. Run the app
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### macOS Host App Setup

#### Running in Development (via Xcode)

1. Open the project in Xcode
```bash
cd macos_host/MacVolumeControl
open MacVolumeControl.xcodeproj
```

2. Build and run the project
   - Select `Product > Run` in Xcode
   - The icon will appear in the menu bar

#### Building as Standalone App (Runs without Xcode)

**Method 1: Archive with Xcode (Recommended)**

1. Select `Product > Archive` in Xcode
2. Select `Distribute App` > `Copy App`
3. Copy the exported `.app` file to the Applications folder
4. Double-click the app in Finder to launch

**Method 2: Build via Command Line**

```bash
cd macos_host/MacVolumeControl
xcodebuild -project MacVolumeControl.xcodeproj \
  -scheme MacVolumeControl \
  -configuration Release \
  -derivedDataPath ./build

# Copy the built app
cp -r ./build/Build/Products/Release/MacVolumeControl.app ~/Applications/
```

**Auto-start on Login (Optional):**
- Add `MacVolumeControl.app` from `System Settings` > `General` > `Login Items`

For more details, see [macOS Host App README](macos_host/README.md).

## Usage

### 1. Launch macOS Host App

Launch the MacVolumeControl app on your macOS device. An icon will appear in the menu bar and BLE service advertising will begin.

### 2. Scan for Devices with Mobile App

1. Launch the mobile app
2. Tap the "Scan for Devices" button
3. Grant Bluetooth permissions
4. Select your macOS device from the discovered devices list

### 3. Control Volume

- **Slider**: Drag to adjust volume (0-100%)
- **Mute Button**: Tap to mute/unmute
- **Connection Status**: Connection status is displayed at the top of the screen

### 4. Disconnect

Tap the "Disconnect" button or close the app to disconnect.

## Testing

### Running Unit Tests

```bash
flutter test
```

### Test Coverage

- BLoC state transition tests
- Debounce processing tests
- Error handling tests
- UI widget tests

## Error Handling

### Mobile App

- **Bluetooth Disabled**: Provides navigation to settings screen
- **Connection Failed**: Automatic retry up to 3 times (5-second intervals)
- **Communication Timeout**: Write 3 seconds, Read 2 seconds
- **Invalid Volume Value**: Clamped to 0-100 range

### macOS Host

- **No Bluetooth Permission**: Displays permission request dialog
- **Invalid Command**: Range check and logging
- **Audio System Error**: Catches errors and retains previous valid value

## Performance Optimization

- **Debounce Processing**: 100ms debounce during slider operation to reduce BLE communication
- **Notification Optimization**: Send notifications only when volume actually changes
- **Low Power Consumption**: Utilizes BLE 4.0+ power-saving features

## Security

- BLE connection pairing (Just Works method)
- Limit concurrent connections to 1 device
- Received data range validation
- Proper Bluetooth permission management

## Project Structure

```
ble-sound-volume/
├── lib/
│   ├── bloc/              # BLoC state management
│   ├── models/            # Data models
│   ├── repositories/      # BLE repository
│   ├── screens/           # UI screens
│   └── main.dart
├── macos_host/
│   └── MacVolumeControl/  # macOS host app
├── test/                  # Test code
└── .kiro/
    └── specs/             # Specifications and design docs
```

## License

MIT License

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Related Documentation

- [Requirements Document](.kiro/specs/mac-volume-control/requirements.md)
- [Design Document](.kiro/specs/mac-volume-control/design.md)
- [Implementation Tasks](.kiro/specs/mac-volume-control/tasks.md)
- [macOS Host Implementation Notes](macos_host/IMPLEMENTATION_NOTES.md)

## Contact

If you have any issues or questions, please let us know on the GitHub Issues page.
