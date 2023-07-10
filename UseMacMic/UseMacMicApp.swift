//
//  UseMacMicApp.swift
//  UseMacMic
//
//  Created by Ігор Побурко on 07.07.2023.
//
import SwiftUI

@main
struct UseMacMicApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
