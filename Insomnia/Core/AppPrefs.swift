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

        // Timer state persistence
        static let timerIsActive = "timerIsActive"
        static let timerIsIndefinite = "timerIsIndefinite"
        static let timerTargetEndDate = "timerTargetEndDate"
    }

    // MARK: - User Preferences

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

    // MARK: - Timer State (internal, not user-facing)
    // Persisted so active timers survive app restarts and crashes.

    /// Whether a timer was active when the app last ran.
    @AppStorage(Keys.timerIsActive) var timerIsActive: Bool = false

    /// Whether the persisted timer was in indefinite mode.
    @AppStorage(Keys.timerIsIndefinite) var timerIsIndefinite: Bool = false

    /// The target end date of the persisted timer (seconds since 1970). Zero means no date.
    @AppStorage(Keys.timerTargetEndDate) var timerTargetEndDate: Double = 0

    // MARK: - Computed Properties

    /// The selected app icon as an `AppIcon` enum value.
    var selectedAppIcon: AppIcon {
        get { AppIcon.from(selectedAppIconRaw) }
        set { selectedAppIconRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    private init() {}
}
