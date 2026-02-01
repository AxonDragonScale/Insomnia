# Installing Insomnia

## Download

Download the latest `Insomnia-x.x.dmg` from the [Releases](https://github.com/axondragonscale/Insomnia/releases) page.

## Installation Steps

1. **Open the DMG file**
   - Double-click `Insomnia-x.x.dmg` to mount it

2. **Drag to Applications**
   - Drag `Insomnia.app` to your Applications folder

3. **First Launch (Important!)**
   
   Since this app is not notarized with Apple, macOS will show a security warning on first launch.
   
   **To open the app:**
   - Right-click (or Control-click) on `Insomnia.app`
   - Select **Open** from the context menu
   - Click **Open** in the dialog that appears
   
   You only need to do this once. After that, the app will open normally.

   **Alternative method:**
   - Try to open the app normally (it will be blocked)
   - Go to **System Settings → Privacy & Security**
   - Scroll down to find the message about Insomnia being blocked
   - Click **Open Anyway**

4. **Grant Permissions (Optional)**
   - When prompted, allow notifications for timer expiry warnings

## Verifying the Download

To verify your download hasn't been tampered with, compare the SHA256 checksum:

```bash
shasum -a 256 ~/Downloads/Insomnia-x.x.dmg
```

Compare the output with the checksum listed in the release notes.

## Uninstallation

1. Quit Insomnia (click the menu bar icon → Quit)
2. Drag `Insomnia.app` from Applications to Trash
3. (Optional) Remove preferences:
   ```bash
   defaults delete com.axondragonscale.Insomnia
   ```

## Why the Security Warning?

This app is distributed outside the Mac App Store and is not notarized with Apple (which requires a $99/year developer membership). 

The app is open source — you can review the [source code](https://github.com/axondragonscale/Insomnia) and build it yourself if you prefer.

## Building from Source

If you'd rather build the app yourself:

1. Clone the repository:
   ```bash
   git clone https://github.com/axondragonscale/Insomnia.git
   ```

2. Open `Insomnia.xcodeproj` in Xcode 16.3+

3. Build and run (⌘R)

Apps built locally on your Mac are automatically trusted by Gatekeeper.

## Requirements

- macOS 15.4 or later

## Troubleshooting

**App won't open at all:**
- Make sure you're using the right-click → Open method
- Check System Settings → Privacy & Security for the "Open Anyway" button

**Timer not preventing sleep:**
- Verify with: `pmset -g assertions` in Terminal
- Look for "Insomnia is keeping the system awake"

**Launch at Login not working:**
- Check System Settings → General → Login Items
- Make sure Insomnia is listed and enabled