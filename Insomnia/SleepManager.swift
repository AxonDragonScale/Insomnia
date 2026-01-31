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

    // MARK: - Properties

    /// The current power assertion ID. `kIOPMNullAssertionID` when no assertion is active.
    private var assertionID: IOPMAssertionID = IOPMAssertionID(kIOPMNullAssertionID)

    /// Indicates whether sleep is currently being blocked.
    private(set) var isPreventingSleep: Bool = false

    /// The reason string shown in system diagnostics (e.g., `pmset -g assertions`).
    private let assertionReason = "Insomnia is keeping the system awake" as CFString

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Prevents the system and display from sleeping.
    /// - Returns: `true` if the assertion was successfully created, `false` otherwise.
    @discardableResult
    func preventSleep() -> Bool {
        // If already preventing sleep, return success
        guard !isPreventingSleep else {
            return true
        }

        // Create a power assertion to prevent display sleep
        // Using kIOPMAssertionTypePreventUserIdleDisplaySleep keeps the display on,
        // which also prevents the lock screen from engaging.
        let assertionType = kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString

        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            assertionReason,
            &assertionID
        )

        if result == kIOReturnSuccess {
            isPreventingSleep = true
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
