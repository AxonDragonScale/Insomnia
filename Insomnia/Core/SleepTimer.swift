//
//  SleepTimer.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation
import AppKit
import Combine

/// ViewModel that manages the countdown timer and coordinates with SleepManager.
///
/// Timer state is persisted to `AppPrefs` so active timers survive app restarts
/// and crashes. On initialization, any previously active timer is restored — if its
/// target time has already passed, the timer stops silently.
@MainActor
final class SleepTimer: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var isActive: Bool = false
    @Published private(set) var isIndefinite: Bool = false
    @Published private(set) var timeRemainingDisplay: String = "00:00"  // Must only be updated when UI is visible to avoid high idle CPU usage

    // MARK: - Private Properties

    private var timer: Timer?
    private var targetEndDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private var notificationSent: Bool = false

    /// Timer tick intervals — 1s for smooth UI countdown, 30s for background expiry checks.
    private enum TickInterval {
        static let foreground: TimeInterval = 1.0
        static let background: TimeInterval = 10.0
    }

    // MARK: - Public Properties

    var isUiVisible: Bool = false {
        didSet {
            if isUiVisible { updateRemainingTime() }
            rescheduleTimerIfNeeded()
        }
    }

    // MARK: - Initialization

    init() {
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in self?.updateRemainingTime() }
            }
            .store(in: &cancellables)

        restoreState()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Public Methods

    func start(until targetTime: Date) {
        let seconds = Int(targetTime.timeIntervalSince(Date()))
        guard seconds >= 60 else { return }
        start(minutes: (seconds + 59) / 60)
    }

    func start(minutes: Int) {
        stop()

        guard SleepManager.shared.preventSleep(preventManualSleep: AppPrefs.shared.preventManualSleep) else {
            return
        }

        isActive = true
        notificationSent = false

        if minutes == -1 {
            isIndefinite = true
            targetEndDate = nil
            timeRemainingDisplay = "∞"
        } else {
            isIndefinite = false
            targetEndDate = Date().addingTimeInterval(Double(minutes * 60))
            updateRemainingTime()
            startTimer()
        }

        persistState()
    }

    func stop(cancelNotifications: Bool = true) {
        timer?.invalidate()
        timer = nil
        SleepManager.shared.allowSleep()

        if cancelNotifications {
            NotificationManager.shared.cancelAllNotifications()
        }

        isActive = false
        isIndefinite = false
        targetEndDate = nil
        timeRemainingDisplay = "00:00"
        notificationSent = false

        clearPersistedState()
    }

    // MARK: - Preference Change Handling

    /// Call when `preventManualSleep` is toggled in settings.
    /// If a timer is active, swaps the IOKit assertion type immediately.
    func handlePreventManualSleepChanged(_ preventManualSleep: Bool) {
        guard isActive else { return }
        SleepManager.shared.preventSleep(preventManualSleep: preventManualSleep)
    }

    // MARK: - Timer

    private func startTimer() {
        let interval = isUiVisible ? TickInterval.foreground : TickInterval.background
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateRemainingTime() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    /// Restarts the timer with the appropriate interval when UI visibility changes.
    private func rescheduleTimerIfNeeded() {
        guard isActive, !isIndefinite, timer != nil else { return }
        timer?.invalidate()
        timer = nil
        startTimer()
    }

    private func updateRemainingTime() {
        guard isActive, !isIndefinite, let targetEndDate else { return }

        let remaining = Int(targetEndDate.timeIntervalSince(Date()))

        if remaining <= 0 {
            NotificationManager.shared.sendCompletionNotification()
            stop(cancelNotifications: false)
            return
        }

        if isUiVisible {
            timeRemainingDisplay = remaining.formattedAsTime
        }

        // Send warning notification if enabled (with guard to prevent duplicates)
        if AppPrefs.shared.notificationEnabled
            && !notificationSent
            && remaining <= AppPrefs.shared.notificationMinutes * 60 {
            notificationSent = true
            NotificationManager.shared.sendWarningNotification(minutesRemaining: AppPrefs.shared.notificationMinutes)
        }
    }

    // MARK: - State Persistence

    /// Saves the current timer state to `AppPrefs` so it can be restored on next launch.
    private func persistState() {
        AppPrefs.shared.timerIsActive = isActive
        AppPrefs.shared.timerIsIndefinite = isIndefinite
        AppPrefs.shared.timerTargetEndDate = targetEndDate?.timeIntervalSince1970 ?? 0
    }

    /// Clears any persisted timer state.
    private func clearPersistedState() {
        AppPrefs.shared.timerIsActive = false
        AppPrefs.shared.timerIsIndefinite = false
        AppPrefs.shared.timerTargetEndDate = 0
    }

    /// Restores a previously active timer from persisted state.
    ///
    /// Called once during `init()`. If the persisted timer was timed and has already
    /// expired, the state is silently cleared. If still valid, the IOKit assertion is
    /// re-created and the countdown resumes from where it left off.
    private func restoreState() {
        guard AppPrefs.shared.timerIsActive else { return }

        // Re-create the IOKit power assertion
        guard SleepManager.shared.preventSleep(preventManualSleep: AppPrefs.shared.preventManualSleep) else {
            clearPersistedState()
            return
        }

        isActive = true

        if AppPrefs.shared.timerIsIndefinite {
            isIndefinite = true
            targetEndDate = nil
            timeRemainingDisplay = "∞"
        } else {
            let endDate = Date(timeIntervalSince1970: AppPrefs.shared.timerTargetEndDate)
            let remaining = Int(endDate.timeIntervalSince(Date()))

            if remaining <= 0 {
                // Timer expired while app was not running — clean up
                SleepManager.shared.allowSleep()
                isActive = false
                clearPersistedState()
                return
            }

            isIndefinite = false
            targetEndDate = endDate
            notificationSent = false
            updateRemainingTime()
            startTimer()
        }
    }
}
