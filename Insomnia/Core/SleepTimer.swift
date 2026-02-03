//
//  SleepTimer.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation
import AppKit

/// ViewModel that manages the countdown timer and coordinates with SleepManager.
@MainActor
final class SleepTimer: ObservableObject {

    // MARK: - Published Properties
    
    @Published private(set) var isActive: Bool = false
    @Published private(set) var isIndefinite: Bool = false
    @Published private(set) var timeRemainingDisplay: String = "00:00"  // Must only be updated when UI is visible to avoid high idle CPU usage

    // MARK: - Private Properties

    private var timer: Timer?
    private var targetEndDate: Date?
    private var wakeObserver: NSObjectProtocol?
    
    // MARK: - Public Properties
    
    var isUiVisible: Bool = false {
        didSet {
            if isUiVisible { updateRemainingTime() }
        }
    }

    // MARK: - Initialization

    init() {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.updateRemainingTime() }
        }
    }

    deinit {
        timer?.invalidate()
        if let observer = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
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
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        SleepManager.shared.allowSleep()
        NotificationManager.shared.cancelAllNotifications()

        isActive = false
        isIndefinite = false
        targetEndDate = nil
        timeRemainingDisplay = "00:00"
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateRemainingTime() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func updateRemainingTime() {
        guard isActive, !isIndefinite, let targetEndDate else { return }

        let remaining = Int(targetEndDate.timeIntervalSince(Date()))

        if remaining <= 0 { stop(); return }

        if isUiVisible {
            timeRemainingDisplay = remaining.formattedAsTime
        }

        // Send warning notification if enabled
        let prefs = AppPrefs.shared
        if prefs.notificationEnabled && remaining == prefs.notificationMinutes * 60 {
            NotificationManager.shared.sendWarningNotification(minutesRemaining: prefs.notificationMinutes)
        }
    }
}
