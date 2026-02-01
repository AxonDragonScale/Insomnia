//
//  SleepManager.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import Foundation
import IOKit.pwr_mgt

/// Manages macOS power assertions to prevent the system from sleeping.
/// Uses IOKit framework to create and release power assertions.
final class SleepManager {

    // MARK: - Singleton

    static let shared = SleepManager()

    // MARK: - Storage Keys

    /// Storage key for the prevent manual sleep setting.
    static let preventManualSleepKey = "preventManualSleep"

    // MARK: - Properties

    /// The current power assertion ID. `kIOPMNullAssertionID` when no assertion is active.
    private var assertionID: IOPMAssertionID = IOPMAssertionID(kIOPMNullAssertionID)

    /// Indicates whether sleep is currently being blocked.
    private(set) var isPreventingSleep: Bool = false

    /// Tracks the current assertion type to detect changes.
    private var currentPreventManualSleep: Bool = false

    /// The reason string shown in system diagnostics (e.g., `pmset -g assertions`).
    private let assertionReason = "Insomnia is keeping the system awake" as CFString

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Prevents the system and display from sleeping.
    /// - Parameter preventManualSleep: If `true`, prevents sleep even from Apple menu or power button.
    ///   If `false`, only prevents idle sleep. Note: Lid close cannot be prevented on MacBooks.
    /// - Returns: `true` if the assertion was successfully created, `false` otherwise.
    @discardableResult
    func preventSleep(preventManualSleep: Bool = false) -> Bool {
        // If already preventing sleep with same settings, return success
        if isPreventingSleep && currentPreventManualSleep == preventManualSleep {
            return true
        }

        // If settings changed, release old assertion first
        if isPreventingSleep {
            allowSleep()
        }

        // Choose assertion type based on setting:
        // - kIOPMAssertionTypePreventUserIdleDisplaySleep: Prevents idle sleep only
        // - kIOPMAssertionTypePreventSystemSleep: Prevents idle + manual sleep (Apple menu, power button)
        let assertionType: CFString = preventManualSleep
            ? kIOPMAssertionTypePreventSystemSleep as CFString
            : kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString

        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            assertionReason,
            &assertionID
        )

        if result == kIOReturnSuccess {
            isPreventingSleep = true
            currentPreventManualSleep = preventManualSleep
            return true
        } else {
            assertionID = IOPMAssertionID(kIOPMNullAssertionID)
            isPreventingSleep = false
            return false
        }
    }

    /// Allows the system to sleep normally by releasing the power assertion.
    /// - Returns: `true` if the assertion was successfully released, `false` otherwise.
    @discardableResult
    func allowSleep() -> Bool {
        // If not currently preventing sleep, return success
        guard isPreventingSleep else {
            return true
        }

        // Release the power assertion
        let result = IOPMAssertionRelease(assertionID)

        // Reset state regardless of result to avoid zombie assertions
        assertionID = IOPMAssertionID(kIOPMNullAssertionID)
        isPreventingSleep = false

        return result == kIOReturnSuccess
    }

    // MARK: - Deinitialization

    deinit {
        // Ensure we release the assertion when the manager is deallocated
        allowSleep()
    }
}
