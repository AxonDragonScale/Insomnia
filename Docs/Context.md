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
├── InsomniaApp.swift              # Entry point, MenuBarExtra setup
├── InsomniaView.swift             # Main container, page navigation
├── Views/
│   ├── AppPage.swift              # Navigation enum (.home, .settings)
│   ├── HomeView.swift             # Timer controls and status
│   └── SettingsView.swift         # App icon and behavior settings
├── Components/
│   ├── AppButton.swift            # Button with icon + title
│   ├── IconButton.swift           # Icon-only button
│   ├── BackgroundGradientView.swift
│   └── BrandingHeaderView.swift   # Header with nav buttons
├── Core/
│   ├── AppPrefs.swift             # Centralized @AppStorage preferences
│   ├── SleepManager.swift         # IOKit power assertions
│   ├── SleepTimer.swift           # Countdown ViewModel
│   ├── LaunchAtLoginManager.swift # SMAppService wrapper
│   └── NotificationManager.swift  # Local notifications
├── Constants/
│   ├── AppColors.swift            # Theme colors
│   ├── AppIcon.swift              # Icon options enum
│   └── Spacing.swift              # Layout constants
├── Utilities/
│   ├── TimeUtil.swift             # Time formatting
│   └── Image+ActiveBadge.swift    # Menu bar icon with badge
├── Scripts/
│   └── build_release.sh           # Distribution build script
└── Docs/                          # Screenshots and documentation
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

## Preferences (AppPrefs)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `selectedAppIcon` | String | `moon` | Menu bar and branding icon |
| `preventManualSleep` | Bool | `false` | Block manual sleep triggers |
| `notificationEnabled` | Bool | `true` | Show notification before expiry |
| `notificationMinutes` | Int | `1` | Minutes before expiry to notify |

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

---

## Quick Reference

| To Change... | Edit File |
|--------------|-----------|
| Menu bar icon | `InsomniaApp.swift` |
| User preferences | `Core/AppPrefs.swift` |
| Timer logic | `Core/SleepTimer.swift` |
| Power assertion | `Core/SleepManager.swift` |
| Launch at login | `Core/LaunchAtLoginManager.swift` |
| Home page UI | `Views/HomeView.swift` |
| Settings UI | `Views/SettingsView.swift` |
| Available icons | `Constants/AppIcon.swift` |
| Theme colors | `Constants/AppColors.swift` |

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
- [ ] Indefinite mode shows ∞
- [ ] Icon changes between active/inactive states
- [ ] Settings persist after restart
- [ ] `pmset -g assertions` shows correct assertion type
- [ ] Manual sleep blocked when setting enabled
- [ ] Launch at Login works (System Settings > General > Login Items)