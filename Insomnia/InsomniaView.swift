//
//  InsomniaView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct InsomniaView: View {

    // ViewModel (owned by InsomniaApp, passed in for menu bar icon updates)
    @ObservedObject var sleepTimer: SleepTimer

    // Navigation state
    @State private var currentPage: AppPage = .home

    var body: some View {
        ZStack {
            // --- Full Background Gradient ---
            BackgroundGradientView()

            VStack(spacing: 0) {
                // --- Branding Header (always visible) ---
                BrandingHeaderView(
                    isActive: sleepTimer.isActive,
                    currentPage: currentPage,
                    onNavigate: { page in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentPage = page
                        }
                    }
                )

                // --- Page Content ---
                Group {
                    switch currentPage {
                    case .home:
                        HomeView(sleepTimer: sleepTimer)
                    case .settings:
                        SettingsView(sleepTimer: sleepTimer)
                    }
                }
                .frame(height: AppDimensions.windowHeight)
                .transition(.opacity)
            }
        }
        .frame(width: AppDimensions.windowWidth)
        .onAppear {
            sleepTimer.isUiVisible = true
        }
        .onDisappear {
            sleepTimer.isUiVisible = false
            currentPage = .home
        }
    }
}

#Preview {
    InsomniaView(sleepTimer: SleepTimer())
}
