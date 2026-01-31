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
