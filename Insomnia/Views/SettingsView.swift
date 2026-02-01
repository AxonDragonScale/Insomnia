//
//  SettingsView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage(AppIcon.storageKey) private var selectedIconRaw: String = AppIcon.defaultIcon.rawValue

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
