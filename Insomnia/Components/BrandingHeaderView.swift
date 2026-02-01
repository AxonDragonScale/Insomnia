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

    var body: some View {
        HStack {
            // App branding
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.white)

            Text("Insomnia")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            // Status dot (only on home page)
            if currentPage == .home {
                Circle()
                    .fill(isActive ? AppColors.activeGreen : AppColors.subtleOverlay)
                    .frame(width: AppDimensions.statusDotSize, height: AppDimensions.statusDotSize)
                    .shadow(radius: isActive ? 2 : 0)
            }

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
            BrandingHeaderView(isActive: false, currentPage: .settings, onNavigate: { _ in })
        }
    }
    .frame(width: AppDimensions.windowWidth)
}
