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
@MainActor
final class SleepTimer: ObservableObject {

    // MARK: - Published Properties

    /// Whether sleep prevention is currently active.
    @Published private(set) var isActive: Bool = false

    /// The formatted time remaining string (e.g., "29:45" or "∞").
    @Published private(set) var timeRemainingDisplay: String = "00:00"

    /// The total seconds remaining. -1 indicates indefinite mode.
    @Published private(set) var secondsRemaining: Int = 0

    // MARK: - Private Properties

    /// The timer that fires every second.
    private var timer: Timer?

    /// Indicates if running in indefinite mode.
    private var isIndefinite: Bool = false

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

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

        isIndefinite = (minutes == -1)

        if isIndefinite {
            // Indefinite mode
            secondsRemaining = -1
            timeRemainingDisplay = "∞"
        } else {
            // Timed mode
            secondsRemaining = minutes * 60
            timeRemainingDisplay = secondsRemaining.formattedAsTime
        }

        isActive = true

        // Start the timer (even for indefinite, to keep state consistent)
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

    /// Called every second by the timer.
    private func tick() {
        // In indefinite mode, just keep running
        guard !isIndefinite else { return }

        // Decrement the countdown
        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            // Timer expired
            stop()
        } else {
            // Update the display
            timeRemainingDisplay = secondsRemaining.formattedAsTime

            // Send one-minute warning notification
            if secondsRemaining == 60 {
                NotificationManager.shared.sendOneMinuteWarning()
            }
        }
    }

    // MARK: - Deinitialization

    deinit {
        timer?.invalidate()
    }
}
