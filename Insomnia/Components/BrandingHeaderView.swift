//
//  BrandingHeaderView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct BrandingHeaderView: View {
    let isActive: Bool
    let currentPage: AppPage
    let onNavigate: (AppPage) -> Void

    @AppStorage(AppIcon.storageKey) private var selectedIconRaw: String = AppIcon.defaultIcon.rawValue

    var body: some View {
        HStack(spacing: Spacing.medium) {
            // App branding with active badge
            Image.withActiveBadge(appIcon: AppIcon.from(selectedIconRaw), isActive: isActive, size: 18)

            Text("INSOMNIA")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .tracking(1)
                .foregroundColor(.white)

            Spacer()

            // Trailing: Settings/Close button
            Button(action: {
                onNavigate(currentPage == .home ? .settings : .home)
            }) {
                Image(systemName: currentPage == .home ? "gearshape.fill" : "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(AppColors.backgroundOverlay)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, Spacing.large)
    }
}

#Preview {
    ZStack {
        BackgroundGradientView()
        VStack {
            BrandingHeaderView(isActive: true, currentPage: .home, onNavigate: { _ in })
                .border(.red)

            BrandingHeaderView(isActive: false, currentPage: .settings, onNavigate: { _ in })
                .border(.red)

        }
    }
    .frame(width: AppDimensions.windowWidth)
}
