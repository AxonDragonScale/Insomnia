//
//  NotificationManager.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation
import UserNotifications

/// Manages local notifications for the Insomnia app.
/// Handles permission requests and scheduling notifications with sound.
final class NotificationManager: NSObject {

    // MARK: - Singleton

    static let shared = NotificationManager()

    // MARK: - Private Properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Notification Identifiers

    private enum NotificationIdentifier {
        static let oneMinuteWarning = "com.insomnia.oneMinuteWarning"
    }

    // MARK: - Initialization

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - Public Methods

    /// Requests authorization for notifications.
    /// Call this when the app launches.
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }

            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    /// Sends a notification warning that the timer will expire in 1 minute.
    func sendOneMinuteWarning() {
        let content = UNMutableNotificationContent()
        content.title = "Insomnia"
        content.body = "Sleep prevention will end in 1 minute"
        content.sound = UNNotificationSound.default

        // Deliver immediately
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.oneMinuteWarning,
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Cancels all pending notifications.
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    /// Cancels the one minute warning notification if it's pending.
    func cancelOneMinuteWarning() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.oneMinuteWarning]
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Allows notifications to be displayed even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound])
    }

    /// Handles user interaction with the notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
