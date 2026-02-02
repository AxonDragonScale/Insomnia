#!/usr/bin/env swift

import Cocoa
import Foundation

// MARK: - Icon Generator for Insomnia App

/// Generates macOS app icons at all required sizes using SF Symbols
/// Run with: swift generate_app_icon.swift

// Icon sizes required for macOS (size@scale)
let iconSizes: [(size: Int, scale: Int, filename: String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png")
]

// MARK: - Icon Theme Configuration

enum IconTheme {
    case release
    case debug

    var name: String {
        switch self {
        case .release: return "Release"
        case .debug: return "Debug"
        }
    }

    var folderName: String {
        switch self {
        case .release: return "AppIcon.appiconset"
        case .debug: return "AppIconDebug.appiconset"
        }
    }

    var gradientColors: [CGColor] {
        switch self {
        case .release:
            // Indigo to purple gradient
            return [
                NSColor(red: 0.30, green: 0.20, blue: 0.65, alpha: 0.95).cgColor,
                NSColor(red: 0.40, green: 0.22, blue: 0.62, alpha: 0.85).cgColor,
                NSColor(red: 0.50, green: 0.25, blue: 0.58, alpha: 0.75).cgColor
            ]
        case .debug:
            // Orange to yellow gradient
            return [
                NSColor(red: 0.85, green: 0.35, blue: 0.10, alpha: 0.95).cgColor,
                NSColor(red: 0.90, green: 0.45, blue: 0.15, alpha: 0.85).cgColor,
                NSColor(red: 0.95, green: 0.55, blue: 0.20, alpha: 0.75).cgColor
            ]
        }
    }

    var symbolTintColor: NSColor {
        switch self {
        case .release:
            return NSColor(red: 1.0, green: 0.98, blue: 0.92, alpha: 1.0) // Warm white/cream
        case .debug:
            return NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Pure white
        }
    }
}

/// Creates the app icon image at the specified pixel size with the given theme
func createAppIcon(pixelSize: Int, theme: IconTheme) -> NSImage {
    let size = NSSize(width: pixelSize, height: pixelSize)
    let image = NSImage(size: size)

    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = CGRect(origin: .zero, size: CGSize(width: pixelSize, height: pixelSize))

    // MARK: - Background with rounded corners (macOS icon shape)
    let cornerRadius = CGFloat(pixelSize) * 0.22 // macOS standard corner radius ratio
    let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Fill with black base first (matching app's BackgroundGradientView)
    context.saveGState()
    backgroundPath.addClip()
    NSColor.black.setFill()
    backgroundPath.fill()
    context.restoreGState()

    // Gradient overlay based on theme
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: theme.gradientColors as CFArray,
        locations: [0.0, 0.5, 1.0]
    )!

    context.saveGState()
    backgroundPath.addClip()
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: CGFloat(pixelSize)),
        end: CGPoint(x: CGFloat(pixelSize), y: 0),
        options: []
    )
    context.restoreGState()

    // MARK: - Subtle inner border for depth
    context.saveGState()
    let borderPath = NSBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), xRadius: cornerRadius, yRadius: cornerRadius)
    NSColor.white.withAlphaComponent(0.15).setStroke()
    borderPath.lineWidth = 1.0
    borderPath.stroke()
    context.restoreGState()

    // MARK: - SF Symbol (moon.zzz.fill)
    let symbolName = "moon.zzz.fill"
    let symbolSize = CGFloat(pixelSize) * 0.55

    // Create SF Symbol configuration with appropriate weight
    let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .medium)

    if let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
        let configuredImage = symbolImage.withSymbolConfiguration(config) ?? symbolImage

        // Get the actual symbol dimensions to center it properly
        let symbolImageSize = configuredImage.size
        let symbolRect = NSRect(
            x: (CGFloat(pixelSize) - symbolImageSize.width) / 2,
            y: (CGFloat(pixelSize) - symbolImageSize.height) / 2,
            width: symbolImageSize.width,
            height: symbolImageSize.height
        )

        // Draw shadow
        context.saveGState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
        shadow.shadowOffset = NSSize(width: 0, height: -CGFloat(pixelSize) * 0.025)
        shadow.shadowBlurRadius = CGFloat(pixelSize) * 0.05
        shadow.set()

        // Create a tinted version of the symbol
        let tintedImage = createTintedImage(from: configuredImage, tintColor: theme.symbolTintColor)

        tintedImage.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        context.restoreGState()
    }

    image.unlockFocus()
    return image
}

/// Creates a tinted version of an SF Symbol
func createTintedImage(from image: NSImage, tintColor: NSColor) -> NSImage {
    let tintedImage = NSImage(size: image.size)
    tintedImage.lockFocus()

    // Draw the original image
    image.draw(in: NSRect(origin: .zero, size: image.size),
               from: .zero,
               operation: .sourceOver,
               fraction: 1.0)

    // Apply tint color using sourceAtop to only color non-transparent pixels
    tintColor.setFill()
    NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)

    tintedImage.unlockFocus()
    return tintedImage
}

/// Saves an NSImage as PNG to the specified path with correct pixel dimensions
func savePNG(image: NSImage, to path: String, pixelSize: Int) -> Bool {
    // Create a bitmap representation with explicit pixel dimensions
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return false
    }

    // Set the size to match pixels (72 DPI equivalent)
    bitmap.size = NSSize(width: pixelSize, height: pixelSize)

    // Draw the image into the bitmap
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
               from: NSRect(origin: .zero, size: image.size),
               operation: .copy,
               fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    // Save as PNG
    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return false
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        return true
    } catch {
        print("Error saving \(path): \(error)")
        return false
    }
}

/// Generates the Contents.json for the AppIcon.appiconset
func generateContentsJSON() -> String {
    let images = iconSizes.map { size, scale, filename -> String in
        """
            {
              "filename" : "\(filename)",
              "idiom" : "mac",
              "scale" : "\(scale)x",
              "size" : "\(size)x\(size)"
            }
        """
    }.joined(separator: ",\n")

    return """
    {
      "images" : [
    \(images)
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
}

/// Generates all icons for a given theme
func generateIcons(for theme: IconTheme, projectRoot: URL) -> Int {
    let outputDir = projectRoot
        .appendingPathComponent("Insomnia")
        .appendingPathComponent("Assets.xcassets")
        .appendingPathComponent(theme.folderName)

    print("")
    print("[\(theme.name) Icon]")
    print("Output: \(outputDir.path)")

    // Create output directory if needed
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: outputDir.path) {
        try? fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
    }

    // Generate icons at all sizes
    var successCount = 0
    for (size, scale, filename) in iconSizes {
        let pixelSize = size * scale
        let image = createAppIcon(pixelSize: pixelSize, theme: theme)
        let outputPath = outputDir.appendingPathComponent(filename).path

        if savePNG(image: image, to: outputPath, pixelSize: pixelSize) {
            print("  ✅ \(filename) (\(pixelSize)x\(pixelSize)px)")
            successCount += 1
        } else {
            print("  ❌ \(filename)")
        }
    }

    // Generate Contents.json
    let contentsPath = outputDir.appendingPathComponent("Contents.json").path
    let contentsJSON = generateContentsJSON()
    do {
        try contentsJSON.write(toFile: contentsPath, atomically: true, encoding: .utf8)
        print("  ✅ Contents.json")
    } catch {
        print("  ❌ Contents.json: \(error)")
    }

    return successCount
}

// MARK: - Main Execution

print("🌙 Insomnia App Icon Generator")
print("==============================")
print("SF Symbol: moon.zzz.fill")

// Determine output directory
let scriptPath = URL(fileURLWithPath: #file)
let projectRoot = scriptPath.deletingLastPathComponent().deletingLastPathComponent()

// Generate both Release and Debug icons
let releaseCount = generateIcons(for: .release, projectRoot: projectRoot)
let debugCount = generateIcons(for: .debug, projectRoot: projectRoot)

print("")
print("==============================")
print("Release: \(releaseCount)/\(iconSizes.count) icons generated")
print("Debug:   \(debugCount)/\(iconSizes.count) icons generated")
print("")
print("Next steps:")
print("1. Open Insomnia.xcodeproj in Xcode")
print("2. Navigate to Assets.xcassets")
print("3. Verify AppIcon and AppIconDebug are populated")
print("4. Build and run to see the new icons")
