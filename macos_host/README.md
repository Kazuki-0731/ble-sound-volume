# Mac Volume Control - macOS Host Application

This is the macOS host application that runs as a menu bar app and provides BLE peripheral functionality for remote volume control.

## Features

- Runs as a menu bar application
- Advertises BLE service for volume control
- Supports volume read, write, and notifications
- Supports mute/unmute functionality
- Real-time system volume monitoring
- Automatic notification to connected mobile devices

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Bluetooth enabled

## Building the Application

1. Open the Xcode project:
   ```bash
   cd macos_host/MacVolumeControl
   open MacVolumeControl.xcodeproj
   ```

2. Select the "MacVolumeControl" scheme and your Mac as the target device

3. Build and run the application (⌘R)

## Permissions

The application requires the following permissions:
- **Bluetooth**: To advertise BLE service and communicate with mobile devices
- **Audio**: To control system volume

These permissions are automatically requested when the app first launches.

## BLE Service Specification

**Service UUID**: `12345678-1234-1234-1234-123456789ABC`

**Characteristics**:
- **Volume Level** (`12345678-1234-1234-1234-123456789ABD`)
  - Type: UInt8 (0-100)
  - Properties: Read, Write, Notify
  
- **Mute State** (`12345678-1234-1234-1234-123456789ABE`)
  - Type: UInt8 (0=unmuted, 1=muted)
  - Properties: Read, Write, Notify

## Usage

1. Launch the application - it will appear in the menu bar with a speaker icon
2. Click the menu bar icon to view connection status and current volume
3. The app will automatically advertise its BLE service as "Mac Volume Control"
4. Connect from your mobile device using the Flutter app
5. Control volume remotely from your mobile device

## Architecture

- **MacVolumeController**: Interfaces with CoreAudio to control system volume
- **VolumeControlPeripheral**: Manages BLE peripheral and GATT service
- **ContentView**: SwiftUI-based menu bar popover interface
- **MacVolumeControlApp**: Main app entry point and menu bar setup

## Troubleshooting

### Bluetooth not working
- Ensure Bluetooth is enabled in System Settings
- Grant Bluetooth permission when prompted
- Check Console.app for error messages

### Volume control not working
- Ensure the app has necessary permissions
- Check that your output device supports volume control
- Some audio devices may not support programmatic volume control

### Connection issues
- Ensure mobile device Bluetooth is enabled
- Keep devices within Bluetooth range (typically 10 meters)
- Try restarting both applications

## Development Notes

The application uses:
- CoreBluetooth framework for BLE peripheral functionality
- CoreAudio framework for system volume control
- SwiftUI for the menu bar interface
- AudioObjectPropertyListener for real-time volume monitoring

## License

This project is part of the BLE Sound Volume Control system.
