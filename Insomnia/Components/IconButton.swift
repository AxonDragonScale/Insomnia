//
//  IconButton.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct IconButton: View {
    let icon: String
    var style: IconButtonStyle = .normal
    let action: () -> Void

    enum IconButtonStyle {
        case normal
        case confirm
        case destructive
    }

    private var background: some View {
        Group {
            switch style {
            case .normal:
                AppColors.backgroundOverlay
            case .confirm:
                AppColors.confirmGreen
            case .destructive:
                AppColors.destructiveGradient
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: AppLayout.iconButtonWidth)
                .padding(.vertical, Spacing.small)
                .background(background)
                .cornerRadius(AppLayout.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.indigo
        HStack(spacing: 12) {
            IconButton(icon: "checkmark", style: .confirm) {}
            IconButton(icon: "xmark", style: .destructive) {}
            IconButton(icon: "gear", style: .normal) {}
        }
        .padding()
    }
}
