# Insomnia - LLM/Agent Context

> Technical reference for AI assistants working on this codebase.

## Overview

macOS menu bar utility that prevents system sleep. Built with SwiftUI, uses IOKit for power assertions.

**Stack:** Swift 5.0 | SwiftUI | macOS 15.4+ | Menu bar agent (`LSUIElement = YES`)

**Bundle ID:** `com.axondragonscale.Insomnia` (Release) / `com.axondragonscale.Insomnia.debug` (Debug)

---

## Project Structure

```
Insomnia/
├── Insomnia/
│   ├── InsomniaApp.swift              # Entry point, MenuBarExtra setup
│   ├── InsomniaView.swift             # Main container, page navigation
│   ├── Views/
│   │   ├── AppPage.swift              # Navigation enum (.home, .settings)
│   │   ├── HomeView.swift             # Timer controls and status
│   │   └── SettingsView.swift         # App icon and behavior settings
│   ├── Components/
│   │   ├── AppButton.swift            # Button with icon + title
│   │   ├── IconButton.swift           # Icon-only button
│   │   ├── BackgroundGradientView.swift
│   │   └── BrandingHeaderView.swift   # Header with nav buttons
│   ├── Core/
│   │   ├── AppPrefs.swift             # Centralized @AppStorage preferences
│   │   ├── SleepManager.swift         # IOKit power assertions
│   │   ├── SleepTimer.swift           # Countdown ViewModel
│   │   ├── LaunchAtLoginManager.swift # SMAppService wrapper
│   │   └── NotificationManager.swift  # Local notifications
│   ├── Constants/
│   │   ├── AppColors.swift            # Theme colors
│   │   ├── AppIcon.swift              # Icon options enum
│   │   └── Spacing.swift              # Layout constants
│   └── Utilities/
│       ├── TimeUtil.swift             # Time formatting
│       └── Image+ActiveBadge.swift    # Menu bar icon with badge
├── Insomnia.xcodeproj/
├── Scripts/
│   └── build_release.sh               # Distribution build script
└── Docs/                              # Screenshots and documentation
```

---

## Architecture

```
InsomniaApp (MenuBarExtra)
    └── InsomniaView (@State currentPage)
            ├── BrandingHeaderView (nav buttons)
            ├── HomeView ─── SleepTimer ─── SleepManager (IOKit)
            │                    └── NotificationManager
            └── SettingsView ─── AppPrefs
```

### Core Components

| Component | Purpose |
|-----------|---------|
| `AppPrefs` | Singleton for all `@AppStorage` preferences |
| `SleepManager` | Creates/releases IOKit power assertions |
| `SleepTimer` | `@MainActor ObservableObject` countdown logic |
| `LaunchAtLoginManager` | `SMAppService` wrapper for login items |
| `AppIcon` | Enum with active/inactive icon pairs |

---

## SleepTimer

The timer uses `targetEndDate` as the source of truth and calculates remaining time on each tick. This ensures correctness after system wake from sleep.

**Key Properties:**
- `isActive` — Whether sleep prevention is active (observed by menu bar icon)
- `isIndefinite` — Whether running in indefinite mode (no countdown)
- `timeRemainingDisplay` — Formatted time string for UI
- `isUiVisible` — Set by view's `onAppear`/`onDisappear` to control updates
- `notificationSent` — Guard flag to prevent duplicate expiry notifications

**CPU Optimization:**
`timeRemainingDisplay` is only updated when `isUiVisible == true`. This prevents unnecessary SwiftUI observer notifications when the menu bar popover is closed, reducing idle CPU usage. The timer tick interval is also adaptive — **1 second** when the popover is open (smooth countdown display) and **10 seconds** when closed (just enough to catch expiry and notification triggers). The timer is rescheduled automatically via `rescheduleTimerIfNeeded()` whenever `isUiVisible` changes. The IOKit assertion keeps the system awake regardless of tick rate.

**State Persistence:**
Timer state (`isActive`, `isIndefinite`, `targetEndDate`) is persisted to `AppPrefs` on every `start()` and cleared on every `stop()`. On initialization, `restoreState()` checks for a previously active timer:
- **Indefinite:** Re-creates the IOKit assertion and resumes indefinite mode.
- **Timed (still valid):** Re-creates the assertion and resumes countdown from the persisted `targetEndDate`.
- **Timed (expired):** Silently clears persisted state — the timer naturally ran out while the app was not running.

This ensures sleep prevention survives app restarts, crashes, and force-quits.

**System Wake Handling:**
Listens to `NSWorkspace.didWakeNotification` via a Combine publisher (stored in `cancellables`) to recalculate remaining time after the system wakes from sleep. If the target time has passed while asleep, the timer stops immediately. The `AnyCancellable` is automatically cleaned up on deallocation — no manual `removeObserver` needed.

**Live Preference Detection:**
`SettingsView` calls `sleepTimer.handlePreventManualSleepChanged(_:)` via an `onChange` modifier when the user toggles `preventManualSleep`. If a timer is active, `SleepManager.preventSleep()` is called immediately with the new value — swapping the IOKit assertion type (idle-only ↔ system-wide) without interrupting the running timer.

**Notification Guard:**
The expiry notification uses a range check (`remaining <= threshold`) with a `notificationSent` flag instead of exact-second matching. This prevents missed notifications from timer jitter and duplicate deliveries.

---

## Preferences (AppPrefs)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `selectedAppIcon` | String | `moon` | Menu bar and branding icon |
| `preventManualSleep` | Bool | `false` | Block manual sleep triggers |
| `notificationEnabled` | Bool | `true` | Show notification before expiry |
| `notificationMinutes` | Int | `1` | Minutes before expiry to notify |

### Timer State (internal, not user-facing)

Persisted so active timers survive app restarts and crashes.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `timerIsActive` | Bool | `false` | Whether a timer was active when the app last ran |
| `timerIsIndefinite` | Bool | `false` | Whether the persisted timer was indefinite |
| `timerTargetEndDate` | Double | `0` | Target end date (seconds since 1970) |

---

## Sleep Prevention Modes

| Setting | Idle | Apple Menu | Power Button | Lid Close |
|---------|------|------------|--------------|-----------|
| Default | ✅ Blocked | ❌ | ❌ | ❌ |
| Prevent Manual Sleep | ✅ Blocked | ✅ Blocked | ✅ Blocked | ❌ Never |

---

## Code Guidelines

1. **Concurrency:** UI updates on `@MainActor`. Timer uses `Task { @MainActor in ... }`
2. **IOKit:** Only in `SleepManager`. Never import in SwiftUI views
3. **Preferences:** Always use `AppPrefs.shared`, not direct `@AppStorage`
4. **Timer:** Must add to `RunLoop.main` with `.common` mode (works when menu open)
5. **CPU:** Only update `@Published` properties when necessary to avoid idle CPU usage

---

## Quick Reference

| To Change... | Edit File |
|--------------|-----------|
| Menu bar icon | `Insomnia/InsomniaApp.swift` |
| User preferences | `Insomnia/Core/AppPrefs.swift` |
| Timer logic | `Insomnia/Core/SleepTimer.swift` |
| Power assertion | `Insomnia/Core/SleepManager.swift` |
| Launch at login | `Insomnia/Core/LaunchAtLoginManager.swift` |
| Home page UI | `Insomnia/Views/HomeView.swift` |
| Settings UI | `Insomnia/Views/SettingsView.swift` |
| Available icons | `Insomnia/Constants/AppIcon.swift` |
| Theme colors | `Insomnia/Constants/AppColors.swift` |

---

## Build Commands

```bash
# Debug build - runs alongside Release version
# Bundle ID: com.axondragonscale.Insomnia.debug

# Release build script
./Scripts/build_release.sh 1.0.0
# Creates: build/Insomnia-1.0.0.dmg, build/Insomnia-1.0.0.zip

# Verify sleep prevention
pmset -g assertions
# Look for "Insomnia is keeping the system awake"
```

---

## Testing Checklist

- [ ] Timer counts down correctly
- [ ] Timer accounts for time elapsed during system sleep
- [ ] Indefinite mode shows ∞ and uses no timer
- [ ] Icon changes between active/inactive states
- [ ] Settings persist after restart
- [ ] `pmset -g assertions` shows correct assertion type
- [ ] Manual sleep blocked when setting enabled
- [ ] Launch at Login works (System Settings > General > Login Items)
- [ ] Low CPU usage when menu bar popover is closed