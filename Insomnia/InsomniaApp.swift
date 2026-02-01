//
//  InsomniaApp.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

@main
struct InsomniaApp: App {

    /// Shared SleepTimer instance owned by the App for menu bar icon updates
    @StateObject private var sleepTimer = SleepTimer()

    /// Shared preferences
    @ObservedObject private var prefs = AppPrefs.shared

    init() {
        // Request notification permissions at app launch
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra {
            InsomniaView(sleepTimer: sleepTimer)
        } label: {
            Image.withActiveBadge(appIcon: prefs.selectedAppIcon, isActive: sleepTimer.isActive)
        }
        .menuBarExtraStyle(.window)
    }
}
