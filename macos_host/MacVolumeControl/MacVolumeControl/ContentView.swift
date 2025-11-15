import SwiftUI

struct ContentView: View {
    @ObservedObject var blePeripheral: VolumeControlPeripheralObservable
    @ObservedObject var volumeController: MacVolumeControllerObservable
    
    init(blePeripheral: VolumeControlPeripheral, volumeController: MacVolumeController) {
        self.blePeripheral = VolumeControlPeripheralObservable(peripheral: blePeripheral)
        self.volumeController = MacVolumeControllerObservable(controller: volumeController)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Mac Volume Control")
                    .font(.headline)
            }
            .padding(.top, 8)
            
            Divider()
            
            // Connection Status
            HStack {
                Circle()
                    .fill(blePeripheral.isConnected ? Color.green : Color.gray)
                    .frame(width: 10, height: 10)
                Text(blePeripheral.isConnected ? "Connected" : "Waiting for connection...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Current Volume Display
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Volume")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: volumeController.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundColor(volumeController.isMuted ? .red : .blue)
                    
                    Text("\(Int(volumeController.currentVolume * 100))%")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if volumeController.isMuted {
                        Text("Muted")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Use your mobile app to control this Mac's volume")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Quit Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(width: 600, height: 400)
    }
}

// MARK: - Observable Wrappers

class VolumeControlPeripheralObservable: ObservableObject {
    @Published var isConnected: Bool = false
    private var peripheral: VolumeControlPeripheral
    private var timer: Timer?
    
    init(peripheral: VolumeControlPeripheral) {
        self.peripheral = peripheral
        
        // Poll connection status periodically
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // In a real implementation, you would track actual connection state
            // For now, we'll keep it simple
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

class MacVolumeControllerObservable: ObservableObject {
    @Published var currentVolume: Float = 0.0
    @Published var isMuted: Bool = false
    
    private var controller: MacVolumeController
    
    init(controller: MacVolumeController) {
        self.controller = controller
        
        // Get initial values
        self.currentVolume = controller.getVolume()
        self.isMuted = controller.getMuteState()
        
        // Observe changes
        controller.observeVolumeChanges { [weak self] volume in
            DispatchQueue.main.async {
                self?.currentVolume = volume
            }
        }
        
        controller.observeMuteChanges { [weak self] muted in
            DispatchQueue.main.async {
                self?.isMuted = muted
            }
        }
    }
}

#Preview {
    ContentView(
        blePeripheral: VolumeControlPeripheral(volumeController: MacVolumeController()),
        volumeController: MacVolumeController()
    )
}
