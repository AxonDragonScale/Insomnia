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
        case normal       // white 0.2 background
        case destructive  // pink→red gradient
    }

    private var backgroundColor: some View {
        Group {
            switch style {
            case .normal:
                Color.white.opacity(0.2)
            case .destructive:
                LinearGradient(
                    colors: [Color.pink.opacity(0.8), Color.red.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
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
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.indigo
        VStack(spacing: 12) {
            AppButton(icon: "10.circle", title: "10 Min") { }
            AppButton(icon: "clock", title: "1 Hour") { }
            AppButton(icon: "timer", title: "Custom Time") { }
            AppButton(icon: "power", title: "Quit Insomnia") { }
            AppButton(icon: "bed.double.fill", title: "Allow Sleep", style: .destructive) { }
        }
        .padding()
    }
}
