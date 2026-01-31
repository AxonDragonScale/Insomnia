//
//  TimeUtil.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation

extension Int {
    /// Formats seconds into a MM:SS or HH:MM:SS string.
    /// - Returns: Formatted time string (e.g., "29:45" or "1:30:00").
    var formattedAsTime: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct TimeInputUtil {
    /// Validates and filters time input in HH:MM AM/PM format.
    /// Allows deletions, rejects invalid character additions.
    /// - Parameters:
    ///   - oldValue: The previous text value
    ///   - newValue: The new text value to validate
    /// - Returns: The validated text (newValue if valid, oldValue if invalid)
    static func validateTimeInput(oldValue: String, newValue: String) -> String {
        // Allow deletions
        if newValue.count < oldValue.count {
            return newValue
        }

        // Validate the new input - if invalid, keep old value
        let upper = newValue.uppercased()

        // Reject if too long
        if upper.count > 8 {
            return oldValue
        }

        // Validate each character at its position
        for (index, char) in upper.enumerated() {
            let isValid: Bool
            switch index {
            case 0:
                // First hour digit: 0 or 1
                isValid = char == "0" || char == "1"
            case 1:
                // Second hour digit: 0-9, but if first is "1", only 0-2
                if char.isNumber {
                    let firstChar = upper.first
                    if firstChar == "1" {
                        isValid = char == "0" || char == "1" || char == "2"
                    } else {
                        isValid = true
                    }
                } else {
                    isValid = false
                }
            case 2:
                isValid = char == ":"
            case 3:
                // First minute digit: 0-5
                if let digit = char.wholeNumberValue {
                    isValid = digit >= 0 && digit <= 5
                } else {
                    isValid = false
                }
            case 4:
                // Second minute digit: 0-9
                isValid = char.isNumber
            case 5:
                isValid = char == " "
            case 6:
                isValid = char == "A" || char == "P"
            case 7:
                isValid = char == "M"
            default:
                isValid = false
            }

            if !isValid {
                return oldValue
            }
        }

        // All characters valid, return uppercased version
        return upper
    }

    /// Parses a time string in HH:MM AM/PM format to a Date.
    /// If the time is in the past, assumes tomorrow.
    /// - Parameter text: Time string in "HH:MM AM" or "HH:MM PM" format
    /// - Returns: A Date with the parsed time, or nil if parsing fails
    static func parseTime(from text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let parsedTime = formatter.date(from: text) else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)

        guard let hour = timeComponents.hour, let minute = timeComponents.minute else {
            return nil
        }

        var targetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = hour
        targetComponents.minute = minute
        targetComponents.second = 0

        guard var targetDate = calendar.date(from: targetComponents) else {
            return nil
        }

        // If the time is in the past, assume it's for tomorrow
        if targetDate <= now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        }

        return targetDate
    }

    /// Returns a formatted time string for one hour from now.
    /// - Returns: Time string in "HH:MM AM" format
    static func oneHourFromNow() -> String {
        let calendar = Calendar.current
        let oneHourLater = calendar.date(byAdding: .hour, value: 1, to: Date()) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: oneHourLater).uppercased()
    }
}
