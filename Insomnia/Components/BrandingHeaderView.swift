//
//  BrandingHeaderView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct BrandingHeaderView: View {
    let isActive: Bool

    var body: some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.white)

            Text("Insomnia")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            // Small status dot
            Circle()
                .fill(isActive ? AppColors.activeGreen : AppColors.subtleOverlay)
                .frame(width: AppLayout.statusDotSize, height: AppLayout.statusDotSize)
                .shadow(radius: isActive ? 2 : 0)
        }
        .padding(.horizontal)
        .padding(.vertical, Spacing.large)
    }
}

#Preview {
    ZStack {
        Color.indigo
        VStack {
            BrandingHeaderView(isActive: true)
            BrandingHeaderView(isActive: false)
        }
    }
}
