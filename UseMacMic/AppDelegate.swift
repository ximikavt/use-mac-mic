//
//  AppDelegate.swift
//  UseMacMic
//
//  Created by Ігор Побурко on 10.07.2023.
//
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static private(set) var instance: AppDelegate!
    var timer: Timer!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
    var statusBarMenu: NSMenu!
    var updateMenuItem = NSMenuItem(title: "Disable AutoUpdate", action: #selector(toggleTimer), keyEquivalent: "a")
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        initializeStatusBarItem()
        iniitalizeMenu()
        startTimer()
    }
    
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
    private func iniitalizeMenu() {
        statusBarMenu = NSMenu()
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
        setMacMic()
        updateStatusBarIcon()
    }
    
    func getAppIcon() -> NSImage {
        return NSImage(systemSymbolName: isMacMicSet() ? "mic.fill" : "mic", accessibilityDescription: "Use Mac Mic")!
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
            updateMenuItem.title = "Enable AutoUpdate"
        } else {
            startTimer()
            updateMenuItem.title = "Disable AutoUpdate"
        }
    }
    
    @objc func updateStatusBarIcon() {
        statusBarItem.button?.image = getAppIcon();
    }
    
    @objc func exitApp() {
        NSApplication.shared.terminate(nil)
    }
}
