//
//  SleepTimer.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications

/// ViewModel that manages the countdown timer and coordinates with SleepManager.
/// Publishes state changes for SwiftUI to observe.
///
/// Note: To reduce CPU usage when the menu bar UI is closed, we minimize
/// published property updates. The menu bar icon only observes `isActive`,
/// so we avoid unnecessary observer notifications for tick updates.
@MainActor
final class SleepTimer: ObservableObject {

    // MARK: - Published Properties

    /// Whether sleep prevention is currently active.
    /// This is the only property observed by the menu bar icon.
    @Published private(set) var isActive: Bool = false

    /// Whether running in indefinite mode (no countdown).
    @Published private(set) var isIndefinite: Bool = false

    /// The formatted time remaining string (e.g., "29:45" or "∞").
    /// Only updated when the popover UI is visible.
    @Published private(set) var timeRemainingDisplay: String = "00:00"

    // MARK: - Private Properties

    /// The timer that fires every second (only in timed mode).
    private var timer: Timer?

    /// Internal tracking of seconds (updated every tick without triggering observers).
    private var secondsRemaining: Int = 0

    /// Whether the UI is currently visible (popover is open).
    /// When false, we skip publishing tick updates to save CPU.
    private var isUiVisible: Bool = false

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

    /// Call this when the popover becomes visible to sync UI state.
    func onUiAppear() {
        isUiVisible = true
        // Sync published properties with internal state
        if isActive && !isIndefinite {
            timeRemainingDisplay = secondsRemaining.formattedAsTime
        }
    }

    /// Call this when the popover is dismissed.
    func onUiDisappear() {
        isUiVisible = false
    }

    /// Starts preventing sleep until the specified time.
    /// - Parameter targetTime: The target time to stay awake until.
    func start(until targetTime: Date) {
        // Calculate seconds until target time
        let secondsUntil = Int(targetTime.timeIntervalSince(Date()))
        guard secondsUntil >= 60 else { return }

        // Convert to minutes (rounding up to ensure we reach the target)
        let minutes = (secondsUntil + 59) / 60
        start(minutes: minutes)
    }

    /// Starts preventing sleep for the specified duration.
    /// - Parameter minutes: Duration in minutes. Use -1 for indefinite.
    func start(minutes: Int) {
        // Stop any existing timer first
        stop()

        // Activate sleep prevention
        guard SleepManager.shared.preventSleep(preventManualSleep: AppPrefs.shared.preventManualSleep) else {
            // Failed to create assertion
            return
        }

        if minutes == -1 {
            isIndefinite = true
            secondsRemaining = -1
            timeRemainingDisplay = "∞"
            isActive = true
            // No timer started in indefinite mode - saves CPU
        } else {
            isIndefinite = false
            secondsRemaining = minutes * 60
            timeRemainingDisplay = secondsRemaining.formattedAsTime
            isActive = true

            // Start the timer only for timed mode
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }

            // Ensure timer fires even when menu is open
            if let timer = timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    /// Stops preventing sleep and resets the timer.
    func stop() {
        // Invalidate the timer
        timer?.invalidate()
        timer = nil

        // Allow system to sleep
        SleepManager.shared.allowSleep()

        // Cancel any pending notifications
        NotificationManager.shared.cancelAllNotifications()

        // Reset state
        isActive = false
        isIndefinite = false
        secondsRemaining = 0
        timeRemainingDisplay = "00:00"
    }

    // MARK: - Private Methods

    /// Called every second by the timer (only in timed mode).
    private func tick() {
        // Decrement the internal countdown
        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            stop()
        } else {
            // Only update published properties if UI is visible
            // This prevents unnecessary SwiftUI observer notifications
            // when the menu bar popover is closed
            if isUiVisible {
                timeRemainingDisplay = secondsRemaining.formattedAsTime
            }

            // Send warning notification if enabled (always check, regardless of UI visibility)
            let prefs = AppPrefs.shared
            if prefs.notificationEnabled && secondsRemaining == prefs.notificationMinutes * 60 {
                NotificationManager.shared.sendWarningNotification(minutesRemaining: prefs.notificationMinutes)
            }
        }
    }

    // MARK: - Deinitialization

    deinit {
        timer?.invalidate()
    }
}
