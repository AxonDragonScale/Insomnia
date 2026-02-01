//
//  AppPrefs.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

/// Centralized preference management for all user settings.
/// Uses @AppStorage for automatic persistence and SwiftUI reactivity.
final class AppPrefs: ObservableObject {

    // MARK: - Singleton

    static let shared = AppPrefs()

    // MARK: - Storage Keys

    private enum Keys {
        static let selectedAppIcon = "selectedAppIcon"
        static let preventManualSleep = "preventManualSleep"
        static let notificationEnabled = "notificationEnabled"
        static let notificationMinutes = "notificationMinutes"
        static let isFirstLaunch = "isFirstLaunch"
    }

    // MARK: - Published Properties

    /// The selected app icon for menu bar and branding.
    @AppStorage(Keys.selectedAppIcon) var selectedAppIconRaw: String = AppIcon.defaultIcon.rawValue

    /// Whether to prevent manual sleep (Apple menu, power button).
    @AppStorage(Keys.preventManualSleep) var preventManualSleep: Bool = false

    /// Whether to show notification before timer expires.
    @AppStorage(Keys.notificationEnabled) var notificationEnabled: Bool = true

    /// Minutes before expiry to trigger notification.
    @AppStorage(Keys.notificationMinutes) var notificationMinutes: Int = 1

    /// Whether this is the first launch of the app. Used for first-launch setup.
    @AppStorage(Keys.isFirstLaunch) var isFirstLaunch: Bool = true

    // MARK: - Computed Properties

    /// The selected app icon as an `AppIcon` enum value.
    var selectedAppIcon: AppIcon {
        get { AppIcon.from(selectedAppIconRaw) }
        set { selectedAppIconRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    private init() {}
}
