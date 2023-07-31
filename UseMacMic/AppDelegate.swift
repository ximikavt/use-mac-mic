//
//  AppDelegate.swift
//  UseMacMic
//
//  Created by Ігор Побурко on 10.07.2023.
//
import SwiftUI
import AudioUnit

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static private(set) var instance: AppDelegate!
    var timer: Timer!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
    var statusBarMenu: NSMenu!;
    var updateMenuItem = NSMenuItem(title: "AutoUpdate", action: #selector(toggleTimer), keyEquivalent: "a");
    var inputDevicesMenuItem = NSMenuItem(
            title: "Select Default Device",
            action: #selector(toggleTimer),
            keyEquivalent: "d"
    )
    var inputDevicesSubmenu: NSMenu!
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        setDefaultDevice()
        initializeStatusBarItem()
        initializeMenu()
        startTimer()
    }
    var defaultDeviceId: AudioDeviceID!
    
    private func startTimer()  {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateStatusBarIcon()
        })
    }
    
    private func initializeStatusBarItem(){
        statusBarItem.button?.image = getAppIcon()
        statusBarItem.button?.image?.isTemplate = true
        statusBarItem.button?.action = #selector(statusBarButtonClicked(sender:))
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusBarItem.button?.target = self
        statusBarItem.button?.title = "\n"
    }
    
    private func initializeMenu() {
        statusBarMenu = NSMenu()
        inputDevicesSubmenu = NSMenu()

        for (index, element) in getAllInputDevices().enumerated() {
            if (isAnInputDevice(deviceID: element)) {
                let item = NSMenuItem()
                item.title = getDeviceNameById(deviceID: element)
                item.action = #selector(setDefaultDeviceId)
                item.keyEquivalent = String(index)
                item.tag = Int(element)
                
                if (element == defaultDeviceId) {
                    item.state = NSControl.StateValue.on
                } else {
                    item.state = NSControl.StateValue.off
                }
                
                inputDevicesSubmenu.addItem(item)
            }
        }
        
        inputDevicesMenuItem.submenu = inputDevicesSubmenu
        updateMenuItem.state = NSControl.StateValue.on
        statusBarMenu.addItem(inputDevicesMenuItem)
        statusBarMenu.addItem(updateMenuItem)

        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(exitApp),
            keyEquivalent: "e"
        )
        statusBarMenu.delegate = self
    }
    
    func toggleSelectedMic() {
        setDefaultDeviceAsActive()
        updateStatusBarIcon()
    }
    
    func getAppIcon() -> NSImage {
        return NSImage(systemSymbolName: isDefauldDeviceActive() ? "mic.fill" : "mic", accessibilityDescription: "Use Mac Mic")!
    }
    
    func getCheckIcon() -> NSImage {
        return NSImage(systemSymbolName: "check", accessibilityDescription: "")!
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type ==  NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: statusBarItem.statusBar!.thickness), in: statusBarItem.button)
            statusBarItem.menu = nil
        } else {
            toggleSelectedMic()
        }
    }
    
    @objc func toggleTimer() {
        if (timer != nil) {
            timer.invalidate()
            timer = nil
            updateMenuItem.state = NSControl.StateValue.off
        } else {
            startTimer()
            updateMenuItem.state = NSControl.StateValue.on
        }
    }
    
    @objc func updateStatusBarIcon() {
        statusBarItem.button?.image = getAppIcon();
    }
    
    @objc func exitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func setDefaultDeviceId(sender: NSMenuItem) {
        defaultDeviceId = AudioDeviceID(sender.tag)
        
        for (_, element) in inputDevicesSubmenu.items.enumerated() {
            element.state = NSControl.StateValue.off
        }
        
        sender.state = NSControl.StateValue.on
        
        updateStatusBarIcon()
    }
    
    private func setDefaultDevice() {
        let requestedDeviceUID = "BuiltInMicrophoneDevice"
        let deviceID = getRequestedDeviceIDFromUIDSubstring(requestedDeviceUID: UnsafeMutablePointer(mutating: (requestedDeviceUID as NSString).utf8String!))

        if deviceID != kAudioDeviceUnknown {
            defaultDeviceId = deviceID
            print("Device ID: \(deviceID)")
        } else {
            print("Requested device not found.")
        }
    }
    
    private func setDefaultDeviceAsActive() {
        setInputDevice(id: defaultDeviceId)
    }
    
    private func setInputDevice(id: AudioDeviceID) {
        setInputDeviceById(deviceID: id)
    }
    
    private func isDefauldDeviceActive() -> Bool {
        return defaultDeviceId == getCurrentlySelectedInputDeviceID()
    }
}
