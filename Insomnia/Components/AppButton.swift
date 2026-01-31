//
//  AppButton.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct AppButton: View {
    // Required
    let icon: String
    let title: String

    // Optional
    var style: AppButtonStyle = .normal

    // Action (last for trailing closure syntax)
    let action: () -> Void

    enum AppButtonStyle {
        case normal  // white 0.2 background
        case destructive  // pink→red gradient
    }

    private var backgroundColor: some View {
        Group {
            switch style {
            case .normal:
                AppColors.backgroundOverlay
            case .destructive:
                AppColors.destructiveGradient
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.small)
            .background(backgroundColor)
            .cornerRadius(AppLayout.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.indigo
        VStack(spacing: 12) {
            AppButton(icon: "10.circle", title: "10 Min") {}
            AppButton(icon: "clock", title: "1 Hour") {}
            AppButton(icon: "timer", title: "Custom Time") {}
            AppButton(icon: "power", title: "Quit Insomnia") {}
            AppButton(icon: "bed.double.fill", title: "Allow Sleep", style: .destructive) {}
        }
        .padding()
    }
}
