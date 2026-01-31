# Insomnia - macOS Anti-Sleep Utility

## Project Overview

**Insomnia** is a lightweight, native macOS menu bar application designed to prevent the operating system from entering sleep mode or locking the screen for a user-configured duration. It serves as a modern, SwiftUI-based alternative to utilities like "Caffeine" or "Amphetamine."

## Technical Stack

* **Language:** Swift
* **UI Framework:** SwiftUI
* **Target:** macOS 13.0+ (Ventura and later)
* **App Lifecycle:** `SwiftUI App` lifecycle with `MenuBarExtra`.
* **Configuration:** `LSUIElement` = `YES` (Agent app, no Dock icon).

## Architecture & Components

### 1. User Interface (`ContentView.swift`)

The UI is a popover view attached to the menu bar icon.

* **Style:** "JetBrains Toolbox" aesthetic. No window chrome, fixed width, dynamic height.
* **Header:** Custom branding (Indigo gradient) with "Insomnia" title.
* **Control State:**
* *Idle:* Shows a grid of duration buttons (10m, 30m, 1h, Indefinite).
* *Active:* Shows a large monospaced countdown timer and a prominent "Stop" button.


* **Theme:** Uses SF Symbols and standard macOS system materials.

### 2. Core Logic (`SleepManager.swift`)

Handles the interaction with the macOS Kernel (IOKit) to manage power assertions.

* **Framework:** `IOKit.pwr_mgt`
* **Mechanism:** Uses `IOPMAssertionCreateWithName` to create a power assertion.
* **Assertion Type:** `kIOPMAssertionTypePreventUserIdleDisplaySleep`. This ensures the display remains on, which prevents the lock screen from engaging.
* **Safety:** Must strictly track the `AssertionID` to release the lock (`IOPMAssertionRelease`) when the timer expires or the app quits.

### 3. State Management (`SleepTimer.swift` / ViewModel)

Connects the UI to the Logic.

* **Role:** Holds the `Timer` object.
* **Responsibility:**
* Starts the countdown when a button is pressed.
* Updates the UI variable `timeRemaining` every second.
* Calls `SleepManager.allowSleep()` when the timer hits zero.



## Current Project Status

* [x] Project configured as Agent (UIElement).
* [x] `MenuBarExtra` entry point established.
* [x] `ContentView` UI fully implemented with Header, Grid, and Footer.
* [x] Implementation of `SleepManager` (IOKit logic).
* [x] Implementation of Timer/ViewModel to connect UI to Logic.

## LLM Instructions

When generating code for this project:

1. **Strict Concurrency:** Ensure all UI updates (especially the timer countdown) are dispatched to the Main Actor/Thread.
2. **Clean Architecture:** Keep the `IOKit` logic isolated in its own class; do not mix kernel calls directly into SwiftUI Views.
3. **Modern Swift:** Use modern syntax (e.g., `if let`, computed properties) and SwiftUI modifiers.
4. **No Dock Icon:** Remember this is a MenuBar-only app; do not assume the existence of a standard `WindowGroup`.
