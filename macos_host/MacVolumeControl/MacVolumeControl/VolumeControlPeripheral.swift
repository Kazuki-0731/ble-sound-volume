import Foundation
import CoreBluetooth
import AppKit

class VolumeControlPeripheral: NSObject, CBPeripheralManagerDelegate {
    // Service and Characteristic UUIDs (matching the design document)
    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    private let volumeCharacteristicUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABD")
    private let muteCharacteristicUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABE")
    
    private var peripheralManager: CBPeripheralManager!
    private var volumeCharacteristic: CBMutableCharacteristic!
    private var muteCharacteristic: CBMutableCharacteristic!
    private var volumeController: MacVolumeController
    
    private var subscribedCentrals: Set<CBCentral> = []
    
    init(volumeController: MacVolumeController) {
        self.volumeController = volumeController
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Observe volume changes from the system
        volumeController.observeVolumeChanges { [weak self] volume in
            self?.notifyVolumeChange(volume)
        }
        
        volumeController.observeMuteChanges { [weak self] muted in
            self?.notifyMuteChange(muted)
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            setupService()
            startAdvertising()
        case .poweredOff:
            print("Bluetooth is powered off")
            showBluetoothError(message: "Bluetoothがオフになっています。システム環境設定でBluetoothをオンにしてください。")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
            showBluetoothError(message: "Bluetooth権限が許可されていません。システム環境設定のプライバシー設定でBluetoothへのアクセスを許可してください。")
        case .unsupported:
            print("Bluetooth is unsupported")
            showBluetoothError(message: "このデバイスはBluetoothをサポートしていません。")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    // MARK: - Error Handling
    
    private func showBluetoothError(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Bluetoothエラー"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "システム環境設定を開く")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                // Open System Preferences
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid == volumeCharacteristicUUID {
            // Read volume
            let volume = volumeController.getVolume()
            let volumePercentage = UInt8(volume * 100)
            request.value = Data([volumePercentage])
            peripheralManager.respond(to: request, withResult: .success)
            print("Read volume: \(volumePercentage)%")
        } else if request.characteristic.uuid == muteCharacteristicUUID {
            // Read mute state
            let muted = volumeController.getMuteState()
            let muteValue: UInt8 = muted ? 1 : 0
            request.value = Data([muteValue])
            peripheralManager.respond(to: request, withResult: .success)
            print("Read mute state: \(muted)")
        } else {
            peripheralManager.respond(to: request, withResult: .attributeNotFound)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == volumeCharacteristicUUID {
                // Write volume
                guard let value = request.value, value.count > 0 else {
                    peripheralManager.respond(to: request, withResult: .invalidAttributeValueLength)
                    continue
                }
                
                let volumePercentage = value[0]
                
                // Validate range (0-100)
                if volumePercentage > 100 {
                    print("Invalid volume value received: \(volumePercentage). Ignoring.")
                    peripheralManager.respond(to: request, withResult: .success)
                    continue
                }
                
                let volume = Float(volumePercentage) / 100.0
                volumeController.setVolume(volume)
                peripheralManager.respond(to: request, withResult: .success)
                print("Set volume to: \(volumePercentage)%")
                
            } else if request.characteristic.uuid == muteCharacteristicUUID {
                // Write mute state
                guard let value = request.value, value.count > 0 else {
                    peripheralManager.respond(to: request, withResult: .invalidAttributeValueLength)
                    continue
                }
                
                let muteValue = value[0]
                let muted = muteValue != 0
                volumeController.setMuteState(muted)
                peripheralManager.respond(to: request, withResult: .success)
                print("Set mute state to: \(muted)")
                
            } else {
                peripheralManager.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic: \(characteristic.uuid)")
        subscribedCentrals.insert(central)
        
        // Send initial values
        if characteristic.uuid == volumeCharacteristicUUID {
            let volume = volumeController.getVolume()
            notifyVolumeChange(volume)
        } else if characteristic.uuid == muteCharacteristicUUID {
            let muted = volumeController.getMuteState()
            notifyMuteChange(muted)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic: \(characteristic.uuid)")
        subscribedCentrals.remove(central)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error starting advertising: \(error.localizedDescription)")
        } else {
            print("Started advertising BLE service")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupService() {
        // Create volume characteristic
        volumeCharacteristic = CBMutableCharacteristic(
            type: volumeCharacteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        // Create mute characteristic
        muteCharacteristic = CBMutableCharacteristic(
            type: muteCharacteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        // Create service
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [volumeCharacteristic, muteCharacteristic]
        
        // Add service to peripheral manager
        peripheralManager.add(service)
        print("Added BLE service with volume and mute characteristics")
    }
    
    private func startAdvertising() {
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "Mac Volume Control"
        ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        print("Stopped advertising BLE service")
    }
    
    // MARK: - Notification Methods
    
    private func notifyVolumeChange(_ volume: Float) {
        guard !subscribedCentrals.isEmpty else { return }
        
        let volumePercentage = UInt8(volume * 100)
        let data = Data([volumePercentage])
        
        let success = peripheralManager.updateValue(
            data,
            for: volumeCharacteristic,
            onSubscribedCentrals: nil
        )
        
        if success {
            print("Notified volume change: \(volumePercentage)%")
        } else {
            print("Failed to notify volume change - queue full")
        }
    }
    
    private func notifyMuteChange(_ muted: Bool) {
        guard !subscribedCentrals.isEmpty else { return }
        
        let muteValue: UInt8 = muted ? 1 : 0
        let data = Data([muteValue])
        
        let success = peripheralManager.updateValue(
            data,
            for: muteCharacteristic,
            onSubscribedCentrals: nil
        )
        
        if success {
            print("Notified mute change: \(muted)")
        } else {
            print("Failed to notify mute change - queue full")
        }
    }
}
