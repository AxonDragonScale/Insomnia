//
//  AppEnvironment.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 01/02/26.
//

import Foundation

/// Utility for accessing the app's build environment and metadata
struct AppInfo {

    /// Prevent instantiation
    private init() {}

    // MARK: - Build Configuration

    /// Returns `true` if the app was built with the Debug configuration
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Returns `true` if the app was built with the Release configuration
    static var isRelease: Bool {
        !isDebug
    }

    // MARK: - App Info

    /// The app's display name (e.g., "Insomnia" or "Insomnia Debug")
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "Insomnia"
    }

    /// The app's marketing version (e.g., "1.0.0")
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// The app's build number (e.g., "1")
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// The app's formatted version string (e.g., "v1.0.0")
    static var formattedVersion: String {
        "v\(appVersion)"
    }

    /// The app's full version string including build number (e.g., "v1.0.0 (1)")
    static var fullVersion: String {
        "v\(appVersion) (\(buildNumber))"
    }

    /// The app's bundle identifier (e.g., "com.axondragonscale.Insomnia")
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.axondragonscale.Insomnia"
    }
}
