//
//  SettingsView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage(AppIcon.storageKey) private var selectedIconRaw: String = AppIcon.defaultIcon.rawValue
    @AppStorage(SleepManager.preventManualSleepKey) private var preventManualSleep: Bool = false

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
                        isSelected: icon == AppIcon.from(selectedIconRaw),
                        onSelect: { selectedIconRaw = icon.rawValue }
                    )
                }
            }
            .padding(.horizontal)

            Divider()
                .background(AppColors.subtleOverlay)
                .padding(.horizontal)
                .padding(.vertical, Spacing.medium)

            // --- Prevent System Sleep Section ---
            Text("Behavior")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.primaryText)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prevent Manual Sleep")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.emphasizedText)

                    Text("Block sleep from Apple menu and power button. Lid close cannot be prevented.")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Toggle("", isOn: $preventManualSleep)
                    .toggleStyle(.switch)
                    .tint(AppColors.activeGreen)
                    .labelsHidden()
            }
            .padding(Spacing.medium)
            .background(AppColors.backgroundOverlay)
            .cornerRadius(AppDimensions.cornerRadius)
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, Spacing.small)
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
    .frame(width: AppDimensions.windowWidth, height: 300)
}
