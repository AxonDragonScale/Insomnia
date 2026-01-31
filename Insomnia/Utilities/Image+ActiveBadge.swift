//
//  MenuBarIconProvider.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import AppKit
import SwiftUI

// MARK: - SwiftUI Image Extension

extension Image {
    
    static func withActiveBadge(systemName: String, isActive: Bool) -> Image {
        let baseIcon = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) ?? NSImage()

        guard isActive else {
            // Use template mode for automatic light/dark adaptation
            baseIcon.isTemplate = true
            return Image(nsImage: baseIcon)
        }

        // Create badged icon with white tint
        let badgeSize: CGFloat = 6
        let padding: CGFloat = 1

        let badgedIcon = NSImage(size: baseIcon.size, flipped: false) { rect in
            // Create a white-tinted version of the icon
            let tintedIcon = NSImage(size: baseIcon.size, flipped: false) { tintRect in
                baseIcon.draw(in: tintRect, from: .zero, operation: .sourceOver, fraction: 1.0)

                // Apply white tint using sourceAtop
                NSColor.white.setFill()
                tintRect.fill(using: .sourceAtop)

                return true
            }

            // Draw the tinted icon
            tintedIcon.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)

            // Calculate badge position (bottom-right corner)
            let badgeX = rect.width - badgeSize - padding
            let badgeY = padding
            let badgeRect = NSRect(x: badgeX, y: badgeY, width: badgeSize, height: badgeSize)

            // Draw badge (green circle)
            NSColor.systemGreen.setFill()
            NSBezierPath(ovalIn: badgeRect).fill()

            return true
        }

        // Don't use template mode when we have a colored badge
        badgedIcon.isTemplate = false

        return Image(nsImage: badgedIcon)
    }

}
