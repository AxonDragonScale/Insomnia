//
//  SettingsView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        VStack(spacing: Spacing.large) {
            // Placeholder content
            Image(systemName: "gearshape.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.primaryText)

            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.emphasizedText)

            Text("Coming soon...")
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .padding(.top, Spacing.extraLarge)
    }
}

#Preview {
    ZStack {
        BackgroundGradientView()
        SettingsView()
    }
    .frame(width: AppDimensions.windowWidth, height: 300)
}
