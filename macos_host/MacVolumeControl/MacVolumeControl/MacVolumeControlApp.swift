import SwiftUI

@main
struct MacVolumeControlApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var volumeController: MacVolumeController?
    var blePeripheral: VolumeControlPeripheral?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize volume controller
        volumeController = MacVolumeController()
        
        // Initialize BLE peripheral
        blePeripheral = VolumeControlPeripheral(volumeController: volumeController!)
        
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "speaker.wave.2", accessibilityDescription: "Volume Control")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 600, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView(
            blePeripheral: blePeripheral!,
            volumeController: volumeController!
        ))
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        blePeripheral?.stopAdvertising()
    }
}
