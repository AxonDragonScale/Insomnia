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
- **Launch at Login:** Optionally start automatically when you log in

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
| `notificationEnabled` | Bool | `true` | Show notification before expiry |
| `notificationMinutes` | Int | `1` | Minutes before expiry to notify (1, 2, 5, 10) |

Launch at Login is managed separately via `Core/LaunchAtLoginManager.swift` using `SMAppService`.

---

## Build & Run

### Debug Build (Development)

1. Open `Insomnia.xcodeproj` in Xcode 16.3+
2. Select **Product → Scheme → Edit Scheme** (⌘<)
3. Set **Build Configuration** to **Debug**
4. Build and run (⌘R)
5. App appears as "Insomnia Debug" in menu bar

### Release Build (Production)

1. Set **Build Configuration** to **Release** in scheme editor
2. Build and run (⌘R)
3. App appears as "Insomnia" in menu bar

**Note:** Debug and Release versions can run simultaneously (different bundle IDs).

| Configuration | Bundle ID | Product Name |
|---------------|-----------|--------------|
| Debug | `com.axondragonscale.Insomnia.debug` | Insomnia Debug |
| Release | `com.axondragonscale.Insomnia` | Insomnia |

**Verify sleep prevention:**
```bash
pmset -g assertions
# Look for "Insomnia is keeping the system awake"
```

---

## Distribution

### Building a Release

Run the build script to create distributable DMG and ZIP files:

```bash
cd Insomnia
./Scripts/build_release.sh 1.0.0
```

This will:
1. Build the Release configuration
2. Create `Insomnia-1.0.0.dmg` with Applications symlink
3. Create `Insomnia-1.0.0.zip` as alternative
4. Generate SHA256 checksums

Output files will be in `build/`.

### GitHub Releases

1. Create a new release with tag `v1.0.0`
2. Upload the DMG and ZIP files
3. Include checksums in release notes:
   ```
   ## Checksums (SHA256)
   - Insomnia-1.0.0.dmg: `<checksum>`
   - Insomnia-1.0.0.zip: `<checksum>`
   ```

### Installation Note

Since the app is not notarized, users need to bypass Gatekeeper on first launch:
- **Right-click → Open → Open**, or
- **System Settings → Privacy & Security → Open Anyway**

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

---

## File Quick Reference

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
- [ ] Launch at Login toggle works (check System Settings > General > Login Items)

---

## Project Files

| File | Purpose |
|------|---------|
| `Scripts/build_release.sh` | Local build script for distribution |
| `INSTALL.md` | User installation instructions |
| `.github/workflows/release.yml` | GitHub Actions workflow for automated releases |

---

## CI/CD with GitHub Actions

### Automated Releases (`release.yml`)

**Trigger via Git tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Or trigger manually:**
1. Go to **Actions → Build and Release**
2. Click **Run workflow**
3. Enter the version number (e.g., `1.0.0`)

The workflow will:
1. Build the Release configuration
2. Create DMG and ZIP files
3. Generate SHA256 checksums
4. Create a GitHub Release with all artifacts
5. Auto-generate release notes from commits

---

## License

Private project by Ronak Harkhani.