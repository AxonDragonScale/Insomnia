//
//  InsomniaApp.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

@main
struct InsomniaApp: App {

    init() {
        // Request notification permissions at app launch
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra("Insomnia", systemImage: "cup.and.saucer.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
