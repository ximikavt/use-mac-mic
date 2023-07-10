//
//  AppDelegate.swift
//  UseMacMic
//
//  Created by Ігор Побурко on 10.07.2023.
//
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    @State private var timer = Timer()
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
    var statusBarMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        initializeStatusBarItem()
        iniitalizeMenu()
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
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(exitApp),
            keyEquivalent: "e"
        )
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
            statusBarItem.button?.performClick(nil)
        } else {
            toggleSelectedMic()
        }
    }
    
    @objc func updateStatusBarIcon() {
        statusBarItem.button?.image = getAppIcon();
    }
    
    @objc func exitApp() {
        NSApplication.shared.terminate(nil)
    }
}
