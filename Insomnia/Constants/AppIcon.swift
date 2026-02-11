//
//  AppIcon.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation

/// Available app icons that users can choose from.
/// Each icon has an active and inactive state.
enum AppIcon: String, CaseIterable, Identifiable {
    case moon
    case cup
    case eye
    case lightbulb
    case bolt
    case flame

    var id: String { rawValue }

    /// The SF Symbol name for the active state.
    var activeSymbolName: String {
        switch self {
        case .moon: return "moon.stars.fill"
        case .cup: return "cup.and.saucer.fill"
        case .eye: return "eye.fill"
        case .lightbulb: return "lightbulb.fill"
        case .bolt: return "bolt.fill"
        case .flame: return "flame.fill"
        }
    }

    /// The SF Symbol name for the inactive state.
    var inactiveSymbolName: String {
        switch self {
        case .moon: return "moon.zzz.fill"
        case .cup: return "cup.and.saucer"
        case .eye: return "eye.slash.fill"
        case .lightbulb: return "lightbulb"
        case .bolt: return "bolt.slash.fill"
        case .flame: return "flame"
        }
    }

    /// Returns the appropriate symbol name based on active state.
    func symbolName(isActive: Bool) -> String {
        isActive ? activeSymbolName : inactiveSymbolName
    }

    /// Human-readable display name for the icon.
    var displayName: String {
        switch self {
        case .moon: return "Moon"
        case .cup: return "Coffee"
        case .eye: return "Eye"
        case .lightbulb: return "Lightbulb"
        case .bolt: return "Bolt"
        case .flame: return "Flame"
        }
    }

    /// The default app icon.
    static let defaultIcon: AppIcon = .moon


}
