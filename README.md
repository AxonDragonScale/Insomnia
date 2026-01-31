# Insomnia - macOS Anti-Sleep Menu Bar Utility

A lightweight, native macOS menu bar application that prevents the system from sleeping or locking the screen for a user-configured duration. Built with SwiftUI as a modern alternative to utilities like "Caffeine" or "Amphetamine."

---

## Table of Contents

- [Technical Stack](#technical-stack)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
- [Component Documentation](#component-documentation)
- [Build & Run](#build--run)
- [Configuration](#configuration)
- [LLM/Agent Instructions](#llmagent-instructions)

---

## Technical Stack

| Aspect | Details |
|--------|---------|
| **Language** | Swift 5.0 |
| **UI Framework** | SwiftUI |
| **Target OS** | macOS 15.4+ (Sequoia) |
| **App Lifecycle** | SwiftUI App with `MenuBarExtra` |
| **App Type** | Agent app (`LSUIElement = YES`) - No Dock icon |
| **Bundle ID** | `com.axondragonscale.Insomnia` |
| **Category** | Utilities |

### Frameworks Used

- **SwiftUI** - User interface
- **IOKit.pwr_mgt** - Power management assertions
- **UserNotifications** - Local notifications
- **Combine** - Reactive state management (via `@Published`)

---

## Project Structure

```
Insomnia/
├── Insomnia.xcodeproj/          # Xcode project file
├── .gitignore                    # Git ignore rules
└── Insomnia/                     # Main source directory
    ├── InsomniaApp.swift         # App entry point
    ├── ContentView.swift         # Main UI view
    ├── SleepManager.swift        # IOKit power assertion logic
    ├── SleepTimer.swift          # Timer ViewModel
    ├── NotificationManager.swift # Local notifications
    ├── Insomnia.entitlements     # App sandbox entitlements
    ├── Assets.xcassets/          # App icons and colors
    │   ├── AccentColor.colorset/
    │   └── AppIcon.appiconset/
    ├── Components/               # Reusable UI components
    │   ├── AppButton.swift
    │   ├── IconButton.swift      # Icon-only button component
    │   ├── BackgroundGradientView.swift
    │   └── BrandingHeaderView.swift
    ├── Constants/                # App-wide constants
    │   ├── AppColors.swift       # Centralized color definitions
    │   └── Spacing.swift         # Spacing and layout constants
    └── Utilities/                # Helper utilities
        └── TimeUtil.swift        # Time formatting extensions
```

---

## Architecture Overview

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        InsomniaApp                          │
│                    (MenuBarExtra entry)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                       ContentView                           │
│              (Main UI - @StateObject sleepTimer)            │
└───────┬─────────────────────────────────────┬───────────────┘
        │                                     │
        ▼                                     ▼
┌───────────────────┐               ┌─────────────────────────┐
│    SleepTimer     │──────────────▶│     SleepManager        │
│    (ViewModel)    │               │   (IOKit Singleton)     │
│  @MainActor       │               │                         │
│  ObservableObject │               │  preventSleep()         │
└───────┬───────────┘               │  allowSleep()           │
        │                           └─────────────────────────┘
        ▼
┌───────────────────┐
│NotificationManager│
│   (Singleton)     │
│                   │
│ 1-minute warning  │
└───────────────────┘
```

### State Management

- **SleepTimer** is an `@MainActor` `ObservableObject` that publishes:
  - `isActive: Bool` - Whether sleep prevention is active
  - `timeRemainingDisplay: String` - Formatted time ("29:45" or "∞")
  - `secondsRemaining: Int` - Raw seconds (-1 for indefinite)

---

## Component Documentation

### 1. InsomniaApp.swift

**Purpose:** App entry point and MenuBarExtra configuration.

```swift
@main
struct InsomniaApp: App {
    var body: some Scene {
        MenuBarExtra("Insomnia", systemImage: "cup.and.saucer.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
```

**Key Points:**
- Uses `MenuBarExtra` with `.window` style (popover, not menu)
- Menu bar icon: `cup.and.saucer.fill` (SF Symbol)
- Requests notification permissions on init

---

### 2. SleepManager.swift

**Purpose:** Manages macOS power assertions via IOKit to prevent sleep.

**Pattern:** Singleton (`SleepManager.shared`)

**Public API:**

| Method | Return | Description |
|--------|--------|-------------|
| `preventSleep()` | `Bool` | Creates power assertion, returns success |
| `allowSleep()` | `Bool` | Releases power assertion, returns success |

**Properties:**
- `isPreventingSleep: Bool` (read-only) - Current state

**IOKit Details:**
- Assertion Type: `kIOPMAssertionTypePreventUserIdleDisplaySleep`
- This keeps the display on AND prevents lock screen
- Assertion visible via `pmset -g assertions` in Terminal

**Critical Safety:**
- Always release assertion on app quit
- Track `assertionID` to avoid orphaned assertions
- `deinit` calls `allowSleep()` as failsafe

---

### 3. SleepTimer.swift

**Purpose:** ViewModel connecting UI to SleepManager, manages countdown.

**Pattern:** `@MainActor ObservableObject`

**Public API:**

| Method | Parameters | Description |
|--------|------------|-------------|
| `start(minutes:)` | `Int` (-1 for indefinite) | Starts sleep prevention |
| `stop()` | None | Stops and resets |

**Published Properties:**
- `isActive: Bool`
- `timeRemainingDisplay: String`
- `secondsRemaining: Int`

**Timer Behavior:**
- Fires every 1 second
- Added to `RunLoop.main` with `.common` mode (works when menu is open)
- Sends 1-minute warning notification before expiry

**Time Formatting:**
- Uses `Int.formattedAsTime` extension from `TimeUtil.swift`
- Under 1 hour: `MM:SS` (e.g., "29:45")
- Over 1 hour: `H:MM:SS` (e.g., "1:30:00")
- Indefinite: "∞" symbol

---

### 4. NotificationManager.swift

**Purpose:** Handles local notifications with sound.

**Pattern:** Singleton (`NotificationManager.shared`), conforms to `UNUserNotificationCenterDelegate`

**Public API:**

| Method | Description |
|--------|-------------|
| `requestAuthorization()` | Request notification permissions |
| `sendOneMinuteWarning()` | Send "1 minute remaining" notification |
| `cancelAllNotifications()` | Cancel all pending/delivered notifications |

**Notification Behavior:**
- Shows banner + plays sound even when app is in foreground
- Identifier: `com.insomnia.oneMinuteWarning`

---

### 5. ContentView.swift

**Purpose:** Main UI view rendered in the MenuBarExtra popover.

**Structure:**
1. **BackgroundGradientView** - Full background
2. **BrandingHeaderView** - Logo, title, status dot
3. **StatusDisplayView** - "Staying Awake" + countdown or "System Normal"
4. **Duration Grid** - 10 Min, 30 Min, 1 Hour, Indefinite buttons
5. **CustomTimeInputView** - Manual minutes input
6. **Footer** - "Allow Sleep" (when active) + "Quit Insomnia"

**State:**
- `@StateObject sleepTimer: SleepTimer`
- `@State showCustomTime: Bool`
- `@State customMinutes: String`

**Layout:**
- Fixed width: 300pt
- Dynamic height (shrinks to fit)

---

### 6. Components/AppButton.swift

**Purpose:** Reusable button with icon + title.

**Parameters:**
- `icon: String` - SF Symbol name
- `title: String` - Button label
- `style: AppButtonStyle` - `.normal` or `.destructive`
- `action: () -> Void` - Tap handler

**Styles:**
- `.normal`: Uses `AppColors.backgroundOverlay`
- `.destructive`: Uses `AppColors.destructiveGradient`

---

### 7. Components/IconButton.swift

**Purpose:** Compact icon-only button for inline actions.

**Parameters:**
- `icon: String` - SF Symbol name
- `style: IconButtonStyle` - `.normal`, `.confirm`, or `.destructive`
- `action: () -> Void` - Tap handler

**Styles:**
- `.normal`: Uses `AppColors.backgroundOverlay`
- `.confirm`: Uses `AppColors.confirmGreen`
- `.destructive`: Uses `AppColors.destructiveGradient`

**Usage:** Used in `CustomTimeInputView` for confirm/cancel actions.

---

### 8. Components/BackgroundGradientView.swift

**Purpose:** Full-bleed gradient background.

**Colors:** Uses `AppColors.backgroundGradient`
- Base: Black
- Overlay: Indigo (60% → 40%) to Purple (30%)
- Direction: Top-leading to bottom-trailing

---

### 9. Components/BrandingHeaderView.swift

**Purpose:** Header with app branding and status indicator.

**Elements:**
- Moon icon (`moon.stars.fill`)
- "Insomnia" title
- Status dot (green when active, dim when idle)

**Uses:** `AppColors.activeGreen`, `AppColors.subtleOverlay`, `AppLayout.statusDotSize`, `Spacing.large`

---

### 10. Constants/AppColors.swift

**Purpose:** Centralized color constants for consistent theming.

**Text Colors:**
- `primaryText` - White 70% opacity
- `secondaryText` - White 60% opacity
- `emphasizedText` - White 90% opacity

**Background Colors:**
- `backgroundOverlay` - White 20% opacity (buttons/inputs)
- `subtleOverlay` - White 30% opacity (dividers/inactive)

**Status Colors:**
- `activeGreen` - Green (status indicators)
- `confirmGreen` - Green 70% opacity (confirm buttons)

**Gradients:**
- `destructiveGradient` - Pink to red (destructive actions)
- `backgroundGradient` - Indigo to purple (app background)

---

### 11. Constants/Spacing.swift

**Purpose:** Consistent spacing and layout dimensions.

**Spacing enum:**
- `small` - 8pt
- `medium` - 12pt
- `large` - 16pt
- `extraLarge` - 24pt

**AppLayout enum:**
- `windowWidth` - 300pt
- `statusAreaHeight` - 80pt
- `countdownHeight` - 50pt
- `statusDotSize` - 12pt
- `iconButtonWidth` - 36pt
- `cornerRadius` - 8pt

---

### 12. Utilities/TimeUtil.swift

**Purpose:** Time formatting utilities.

**Int Extension:**
```swift
extension Int {
    var formattedAsTime: String
}
```

Converts seconds to formatted time string:
- Under 1 hour: `MM:SS` (e.g., "29:45")
- Over 1 hour: `H:MM:SS` (e.g., "1:30:00")

---

## Build & Run

### Requirements

- Xcode 16.3+
- macOS 15.4+ (for deployment)

### Steps

1. Open `Insomnia.xcodeproj` in Xcode
2. Select the "Insomnia" scheme
3. Build and run (⌘R)

### Verification

The app will appear as a cup icon in the menu bar. Click to open the popover.

To verify sleep prevention is working:
```bash
pmset -g assertions
```

Look for an assertion with reason "Insomnia is keeping the system awake".

---

## Configuration

### Entitlements (Insomnia.entitlements)

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

### Info.plist Keys (via Build Settings)

- `LSUIElement = YES` - Hides from Dock (agent app)
- `LSApplicationCategoryType = public.app-category.utilities`

---

## LLM/Agent Instructions

### Code Style Guidelines

1. **Strict Concurrency:** All UI updates MUST be on `@MainActor`. Timer callbacks use `Task { @MainActor in ... }`.

2. **Clean Architecture:**
   - IOKit logic stays in `SleepManager` only
   - Never import `IOKit` in SwiftUI views
   - ViewModels are `@MainActor ObservableObject`

3. **Modern Swift:**
   - Use `if let` unwrapping
   - Prefer computed properties over methods for derived state
   - Use trailing closure syntax

4. **SwiftUI Patterns:**
   - `@StateObject` for owned ViewModels
   - `@Published` for observable state
   - Extract subviews to reduce `body` complexity

### Common Modification Patterns

#### Adding a New Duration Button

1. In `ContentView.swift`, add to the `LazyVGrid`:
```swift
AppButton(icon: "2.circle", title: "2 Hours") { sleepTimer.start(minutes: 120) }
```

#### Adding a New Notification

1. Add identifier in `NotificationManager.swift`:
```swift
static let newNotification = "com.insomnia.newNotification"
```

2. Add method to send it:
```swift
func sendNewNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Insomnia"
    content.body = "Your message here"
    content.sound = .default
    // ... schedule
}
```

3. Call from `SleepTimer.tick()` at appropriate condition.

#### Changing the Menu Bar Icon

In `InsomniaApp.swift`, change the `systemImage` parameter:
```swift
MenuBarExtra("Insomnia", systemImage: "moon.fill") { ... }
```

#### Adding Persistent Settings

1. Add `@AppStorage` property in the view or ViewModel
2. Consider creating a `SettingsManager` singleton for complex settings

### Important Gotchas

1. **Timer in Menu:** Timer must be added to `RunLoop.main` with `.common` mode, otherwise it pauses when the menu popover is open.

2. **Power Assertion Cleanup:** Always call `allowSleep()` before app terminates. The `deinit` in `SleepManager` handles this, but explicit cleanup is safer.

3. **No WindowGroup:** This is a MenuBarExtra-only app. Do NOT add `WindowGroup` - it will create an unwanted window.

4. **Notification Permissions:** Notifications require user permission. The app requests on launch but handles denial gracefully.

5. **Sandbox Limitations:** The app is sandboxed. IOKit power assertions work within the sandbox, but file access is limited.

### Testing Checklist

- [ ] Timer counts down correctly
- [ ] Indefinite mode shows ∞ and doesn't countdown
- [ ] "Allow Sleep" button appears only when active
- [ ] Status dot turns green when active
- [ ] 1-minute warning notification fires
- [ ] `pmset -g assertions` shows assertion when active
- [ ] `pmset -g assertions` shows NO assertion after stop/quit
- [ ] Timer continues when menu popover is open
- [ ] App doesn't appear in Dock
- [ ] Custom time input validates positive integers

### File Modification Quick Reference

| To Change... | Edit File |
|--------------|-----------|
| Menu bar icon | `InsomniaApp.swift` |
| Duration options | `ContentView.swift` |
| Timer logic | `SleepTimer.swift` |
| Power assertion type | `SleepManager.swift` |
| Notification text/timing | `NotificationManager.swift` |
| Button styling | `Components/AppButton.swift` |
| Icon-only buttons | `Components/IconButton.swift` |
| Background colors | `Components/BackgroundGradientView.swift` |
| Header layout | `Components/BrandingHeaderView.swift` |
| Theme colors | `Constants/AppColors.swift` |
| Spacing/dimensions | `Constants/Spacing.swift` |
| Time formatting | `Utilities/TimeUtil.swift` |
| App permissions | `Insomnia.entitlements` |

---

## Current Status

- [x] Project configured as Agent (UIElement)
- [x] MenuBarExtra entry point established
- [x] ContentView UI with Header, Grid, and Footer
- [x] SleepManager IOKit implementation
- [x] SleepTimer ViewModel with countdown
- [x] NotificationManager with 1-minute warning
- [x] Reusable UI components extracted
- [x] Custom time input support
- [x] Centralized color constants (`AppColors`)
- [x] Centralized spacing/layout constants (`Spacing`, `AppLayout`)
- [x] Time formatting utility (`TimeUtil`)
- [x] Icon-only button component (`IconButton`)

---

## License

Private project by Ronak Harkhani.