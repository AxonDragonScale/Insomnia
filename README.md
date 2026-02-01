# Insomnia - macOS Anti-Sleep Menu Bar Utility

A lightweight macOS menu bar app that prevents system sleep for a configured duration. Built with SwiftUI.

---

## Technical Stack

| Aspect | Details |
|--------|---------|
| Language | Swift 5.0 |
| UI | SwiftUI |
| Target | macOS 15.4+ |
| App Type | Menu bar agent (`LSUIElement = YES`) |
| Bundle ID | `com.axondragonscale.Insomnia` |

**Frameworks:** SwiftUI, IOKit.pwr_mgt, UserNotifications

---

## Project Structure

```
Insomnia/
├── InsomniaApp.swift              # App entry point
├── InsomniaView.swift             # Main container with page navigation
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
│   ├── AppPrefs.swift             # Centralized preferences (@AppStorage)
│   ├── SleepManager.swift         # IOKit power assertions
│   ├── SleepTimer.swift           # Countdown ViewModel
│   └── NotificationManager.swift  # Local notifications
├── Constants/
│   ├── AppColors.swift            # Theme colors
│   ├── AppIcon.swift              # Available icon options
│   └── Spacing.swift              # Layout constants
└── Utilities/
    ├── TimeUtil.swift             # Time formatting
    └── Image+ActiveBadge.swift    # Menu bar icon with badge
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

### Key Components

| Component | Purpose |
|-----------|---------|
| `AppPrefs` | Singleton managing all `@AppStorage` preferences |
| `SleepManager` | Creates/releases IOKit power assertions |
| `SleepTimer` | `@MainActor ObservableObject` with countdown logic |
| `AppIcon` | Enum with active/inactive icon pairs |

---

## Features

- **Duration Options:** 10 min, 30 min, 1 hour, indefinite, custom minutes, until specific time
- **Customizable Icon:** 6 icon options with active/inactive states
- **Prevent Manual Sleep:** Optional setting to block Apple menu/power button sleep
- **1-Minute Warning:** Notification before timer expires

### Sleep Prevention Modes

| Setting | Idle | Apple Menu | Power Button | Lid Close |
|---------|------|------------|--------------|-----------|
| Default | ✅ Blocked | ❌ | ❌ | ❌ |
| Prevent Manual Sleep | ✅ Blocked | ✅ Blocked | ✅ Blocked | ❌ Never blocked |

---

## Preferences (AppPrefs)

All user settings are centralized in `Core/AppPrefs.swift`:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `selectedAppIcon` | String | `moon` | Menu bar and branding icon |
| `preventManualSleep` | Bool | `false` | Block manual sleep triggers |

---

## Build & Run

1. Open `Insomnia.xcodeproj` in Xcode 16.3+
2. Build and run (⌘R)
3. App appears as icon in menu bar

**Verify sleep prevention:**
```bash
pmset -g assertions
# Look for "Insomnia is keeping the system awake"
```

---

## File Quick Reference

| To Change... | Edit File |
|--------------|-----------|
| Menu bar icon | `InsomniaApp.swift` |
| User preferences | `Core/AppPrefs.swift` |
| Timer logic | `Core/SleepTimer.swift` |
| Power assertion | `Core/SleepManager.swift` |
| Home page UI | `Views/HomeView.swift` |
| Settings UI | `Views/SettingsView.swift` |
| Available icons | `Constants/AppIcon.swift` |
| Theme colors | `Constants/AppColors.swift` |
| Layout dimensions | `Constants/Spacing.swift` |

---

## Code Guidelines

1. **Concurrency:** UI updates on `@MainActor`. Timer uses `Task { @MainActor in ... }`
2. **IOKit:** Only in `SleepManager`. Never import in SwiftUI views
3. **Preferences:** Always use `AppPrefs.shared`, not direct `@AppStorage`
4. **Timer:** Must add to `RunLoop.main` with `.common` mode (works when menu open)

---

## Testing Checklist

- [ ] Timer counts down correctly
- [ ] Indefinite mode shows ∞
- [ ] Icon changes between active/inactive states
- [ ] Settings persist after restart
- [ ] `pmset -g assertions` shows correct assertion type
- [ ] Manual sleep blocked when setting enabled

---

## License

Private project by Ronak Harkhani.