//
//  AppColors.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

/// Centralized color constants for the Insomnia app theme.
enum AppColors {

    // MARK: - Text Colors

    /// Primary text color (white with 70% opacity)
    static let primaryText = Color.white.opacity(0.7)

    /// Secondary text color (white with 60% opacity)
    static let secondaryText = Color.white.opacity(0.6)

    /// Emphasized text color (white with 90% opacity)
    static let emphasizedText = Color.white.opacity(0.9)

    // MARK: - Background Colors

    /// Standard button/input background overlay (white with 20% opacity)
    static let backgroundOverlay = Color.white.opacity(0.2)

    /// Subtle overlay for dividers and inactive elements (white with 30% opacity)
    static let subtleOverlay = Color.white.opacity(0.3)

    // MARK: - Status Colors

    /// Active/enabled state color
    static let activeGreen = Color.green

    /// Confirmation button color
    static let confirmGreen = Color.green.opacity(0.7)

    // MARK: - Gradient Colors

    /// Background gradient colors
    static let gradientIndigo = Color.indigo
    static let gradientPurple = Color.purple

    // MARK: - Gradients

    /// Destructive action gradient (pink to red)
    static var destructiveGradient: LinearGradient {
        LinearGradient(
            colors: [Color.pink.opacity(0.8), Color.red.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Background gradient overlay
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                gradientIndigo.opacity(0.6),
                gradientIndigo.opacity(0.4),
                gradientPurple.opacity(0.3),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
