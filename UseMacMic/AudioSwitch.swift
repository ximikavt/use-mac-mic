//
//  AudioSwitch.swift
//  UseMacMic
//
//  Created by Ігор Побурко on 19.07.2023.
//

import Foundation
import AudioUnit

public func getDeviceNameById(deviceID: AudioDeviceID) -> String {
    var deviceName = [CChar](repeating: 0, count: 256)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceNameCFString,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var cfDeviceName: Unmanaged<CFString>? = nil
    var dataSize = UInt32(MemoryLayout<CFString?>.size)
    
    let result = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &cfDeviceName)
    if result == noErr, let cfDeviceNameValue = cfDeviceName?.takeUnretainedValue() {
        CFStringGetCString(cfDeviceNameValue, &deviceName, 256, CFStringBuiltInEncodings.UTF8.rawValue)
        return String(cString: deviceName)
    }
    
    return "Unknown Device"
}

public func setInputDeviceById(deviceID: AudioDeviceID) {
    var propertySize: UInt32 = 0
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    let result:OSStatus = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, UInt32(MemoryLayout<AudioObjectPropertyAddress>.size), nil, &propertySize)

    if (result != 0) {
        print("Error \(result) from AudioObjectGetPropertyDataSize")
        return
    }
    var id = UInt32(deviceID)
    AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, propertySize, &id);
}

public func getAllInputDevices() -> [AudioDeviceID] {
    var propertySize: UInt32 = 0
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize)

    let numDevices = Int(propertySize / UInt32(MemoryLayout<AudioDeviceID>.size))

    var devids = [AudioDeviceID]()
    for _ in 0..<numDevices {
        devids.append(AudioDeviceID())
    }
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &devids)
    return devids
}

public func getRequestedDeviceIDFromUIDSubstring(requestedDeviceUID: UnsafeMutablePointer<CChar>) -> AudioDeviceID {
    let devids = getAllInputDevices()
    
    for (_, element) in devids.enumerated() {
        if (isAnInputDevice(deviceID: element)) {
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceUID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: element
            )
            var propertySize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
            var deviceUID = [CChar](repeating: 0, count: 256)
            var deviceUIDRef: Unmanaged<CFString>? = nil
            AudioObjectGetPropertyData(element, &address, 0, nil, &propertySize, &deviceUIDRef);
            CFStringGetCString(deviceUIDRef!.takeUnretainedValue(), &deviceUID, MemoryLayout<CChar>.size * 256, CFStringGetSystemEncoding())
            
            if strstr(deviceUID, requestedDeviceUID) != nil {
                return element
            }
        }
    }
    return kAudioDeviceUnknown
}

public func getCurrentlySelectedInputDeviceID() -> AudioDeviceID {
    
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    var deviceID = kAudioDeviceUnknown;
    var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size);
    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceID);
    if (status != noErr) {
        print("Error getting Currently Selected Input DeviceID");
        return kAudioDeviceUnknown;
    }

    return deviceID;
}

public func isAnInputDevice(deviceID: AudioDeviceID) -> Bool {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreams,
        mScope: kAudioDevicePropertyScopeInput,
        mElement: kAudioObjectPropertyElementMain
    )
    var dataSize = UInt32(0);
    let result = AudioObjectGetPropertyDataSize(
        deviceID,
        &address,
        UInt32(MemoryLayout<AudioClassDescription>.size),
        nil,
        &dataSize
    );
    if (result == noErr && dataSize > 0) {
        return true;
    }
    return false;
}
