//
//  LaunchAtLoginManager.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation
import ServiceManagement

/// Manages the "Launch at Login" functionality using SMAppService.
/// This allows the app to automatically start when the user logs in.
@MainActor
final class LaunchAtLoginManager: ObservableObject {

    // MARK: - Singleton

    static let shared = LaunchAtLoginManager()

    // MARK: - Published Properties

    /// Whether the app is set to launch at login.
    @Published var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled { updateLaunchAtLogin() }
        }
    }

    // MARK: - Initialization

    private init() {
        // Initialize with current registration status
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Public Methods

    /// Refreshes the current launch at login status from the system.
    func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Private Methods

    private func updateLaunchAtLogin() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(isEnabled ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            // Revert the published value if the operation failed
            Task { @MainActor in
                self.isEnabled = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
