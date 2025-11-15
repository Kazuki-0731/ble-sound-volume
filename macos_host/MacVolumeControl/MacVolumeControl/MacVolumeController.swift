import Foundation
import CoreAudio

class MacVolumeController {
    private var volumeChangeCallback: ((Float) -> Void)?
    private var muteChangeCallback: ((Bool) -> Void)?
    private var defaultOutputDeviceID: AudioDeviceID = 0
    
    init() {
        setupDefaultOutputDevice()
        setupVolumeListener()
        setupMuteListener()
    }
    
    deinit {
        removeVolumeListener()
        removeMuteListener()
    }
    
    // MARK: - Public Methods
    
    func getVolume() -> Float {
        var volume: Float32 = 0.0
        var volumeSize = UInt32(MemoryLayout<Float32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            &volumeSize,
            &volume
        )
        
        if status != noErr {
            print("Error getting volume: \(status)")
            return 0.0
        }
        
        return volume
    }
    
    func setVolume(_ volume: Float) {
        // Clamp volume to valid range
        let clampedVolume = max(0.0, min(1.0, volume))
        var volumeValue = clampedVolume
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<Float32>.size),
            &volumeValue
        )
        
        if status != noErr {
            print("Error setting volume: \(status)")
        }
    }
    
    func getMuteState() -> Bool {
        var muted: UInt32 = 0
        var mutedSize = UInt32(MemoryLayout<UInt32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            &mutedSize,
            &muted
        )
        
        if status != noErr {
            print("Error getting mute state: \(status)")
            return false
        }
        
        return muted != 0
    }
    
    func setMuteState(_ muted: Bool) {
        var muteValue: UInt32 = muted ? 1 : 0
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<UInt32>.size),
            &muteValue
        )
        
        if status != noErr {
            print("Error setting mute state: \(status)")
        }
    }
    
    func observeVolumeChanges(callback: @escaping (Float) -> Void) {
        self.volumeChangeCallback = callback
    }
    
    func observeMuteChanges(callback: @escaping (Bool) -> Void) {
        self.muteChangeCallback = callback
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultOutputDevice() {
        var deviceID: AudioDeviceID = 0
        var deviceIDSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &deviceIDSize,
            &deviceID
        )
        
        if status == noErr {
            defaultOutputDeviceID = deviceID
        } else {
            print("Error getting default output device: \(status)")
        }
    }
    
    private func setupVolumeListener() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        AudioObjectAddPropertyListener(
            defaultOutputDeviceID,
            &address,
            volumeChangeListener,
            selfPointer
        )
    }
    
    private func setupMuteListener() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        AudioObjectAddPropertyListener(
            defaultOutputDeviceID,
            &address,
            muteChangeListener,
            selfPointer
        )
    }
    
    private func removeVolumeListener() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        AudioObjectRemovePropertyListener(
            defaultOutputDeviceID,
            &address,
            volumeChangeListener,
            selfPointer
        )
    }
    
    private func removeMuteListener() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        AudioObjectRemovePropertyListener(
            defaultOutputDeviceID,
            &address,
            muteChangeListener,
            selfPointer
        )
    }
}

// MARK: - Audio Property Listeners

private func volumeChangeListener(
    inObjectID: AudioObjectID,
    inNumberAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    inClientData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let clientData = inClientData else { return noErr }
    
    let controller = Unmanaged<MacVolumeController>.fromOpaque(clientData).takeUnretainedValue()
    let volume = controller.getVolume()
    
    DispatchQueue.main.async {
        controller.volumeChangeCallback?(volume)
    }
    
    return noErr
}

private func muteChangeListener(
    inObjectID: AudioObjectID,
    inNumberAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    inClientData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let clientData = inClientData else { return noErr }
    
    let controller = Unmanaged<MacVolumeController>.fromOpaque(clientData).takeUnretainedValue()
    let muted = controller.getMuteState()
    
    DispatchQueue.main.async {
        controller.muteChangeCallback?(muted)
    }
    
    return noErr
}
