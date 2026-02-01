//
//  SettingsView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject private var prefs = AppPrefs.shared
    @ObservedObject private var launchManager = LaunchAtLoginManager.shared

    var body: some View {
        VStack(spacing: Spacing.medium) {
            // --- Icon Selection Section ---
            Text("App Icon")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.primaryText)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            HStack(spacing: Spacing.medium) {
                ForEach(AppIcon.allCases) { icon in
                    IconOption(
                        icon: icon,
                        isSelected: icon == prefs.selectedAppIcon,
                        onSelect: { prefs.selectedAppIcon = icon }
                    )
                }
            }
            .padding(.horizontal)

            Divider()
                .background(AppColors.subtleOverlay)
                .padding(.horizontal)
                .padding(.vertical, Spacing.small)

            // --- Prevent System Sleep Section ---
            Text("Behavior")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.primaryText)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            SettingsToggle(
                title: "Launch at Login",
                subtitle: "Automatically start Insomnia when you log in.",
                isOn: $launchManager.isEnabled
            )

            SettingsToggle(
                title: "Prevent Manual Sleep",
                subtitle: "Block sleep from Apple menu and power button. Lid close cannot be prevented.",
                isOn: $prefs.preventManualSleep
            )

            NotificationSettings(
                isEnabled: $prefs.notificationEnabled,
                minutes: $prefs.notificationMinutes
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, Spacing.small)
    }
}

// MARK: - Notification Settings Row

private struct NotificationSettings: View {
    @Binding var isEnabled: Bool
    @Binding var minutes: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Expiry Notification")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.emphasizedText)

                HStack(spacing: 4) {
                    Text("Notify")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)

                    Picker("", selection: $minutes) {
                        Text("1 min").tag(1)
                        Text("2 min").tag(2)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.activeGreen)
                    .scaleEffect(0.85, anchor: .leading)
                    .disabled(!isEnabled)
                    .opacity(isEnabled ? 1 : 0.5)
                    .frame(width: 80)
                    .padding(.horizontal, -8)

                    Text("before expiry")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.leading, -4)
                }
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
                .tint(AppColors.activeGreen)
                .labelsHidden()
        }
        .padding(Spacing.medium)
        .background(AppColors.backgroundOverlay)
        .cornerRadius(AppDimensions.cornerRadius)
        .padding(.horizontal)
    }
}

// MARK: - Settings Toggle

private struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.emphasizedText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(AppColors.activeGreen)
                .labelsHidden()
        }
        .padding(Spacing.medium)
        .background(AppColors.backgroundOverlay)
        .cornerRadius(AppDimensions.cornerRadius)
        .padding(.horizontal)
    }
}

// MARK: - Icon Option View

private struct IconOption: View {
    let icon: AppIcon
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(systemName: icon.activeSymbolName)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(isSelected ? AppColors.activeGreen.opacity(0.6) : AppColors.backgroundOverlay)
                .cornerRadius(AppDimensions.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                        .stroke(isSelected ? AppColors.activeGreen : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        BackgroundGradientView()
        SettingsView()
    }
    .frame(
        width: AppDimensions.windowWidth,
        height: AppDimensions.windowHeight
    )
}
