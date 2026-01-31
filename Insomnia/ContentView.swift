//
//  ContentView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct ContentView: View {
    // ViewModel
    @StateObject private var sleepTimer = SleepTimer()

    // Local UI state
    @State private var showCustomTime = false
    @State private var customMinutes: String = ""

    // Grid layout for buttons
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            // --- Full Background Gradient ---
            BackgroundGradientView()

            VStack(spacing: 0) {

                // --- 1. Branding Header ---
                BrandingHeaderView(isActive: sleepTimer.isActive)

                // --- 2. Main Status Area ---
                StatusDisplayView(
                    isActive: sleepTimer.isActive,
                    secondsRemaining: sleepTimer.secondsRemaining,
                    timeRemainingDisplay: sleepTimer.timeRemainingDisplay
                )

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 24)

                // --- 3. Duration Selection ---
                Text("Keep Awake For")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .padding(.bottom, 8)

                LazyVGrid(columns: columns, spacing: 8) {
                    AppButton(icon: "10.circle", title: "10 Min") { sleepTimer.start(minutes: 10) }
                    AppButton(icon: "30.circle", title: "30 Min") { sleepTimer.start(minutes: 30) }
                    AppButton(icon: "clock", title: "1 Hour") { sleepTimer.start(minutes: 60) }
                    AppButton(icon: "infinity", title: "Indefinite") { sleepTimer.start(minutes: -1) }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // --- 4. Custom Time Input ---
                CustomTimeInputView(
                    showCustomTime: $showCustomTime,
                    customMinutes: $customMinutes,
                    onStart: { minutes in
                        sleepTimer.start(minutes: minutes)
                    }
                )
                
                Spacer(minLength: 24)

                // --- 5. Footer ---
                if sleepTimer.isActive {
                    AppButton(icon: "bed.double.fill", title: "Allow Sleep", style: .destructive) {
                        sleepTimer.stop()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // --- 6. Bottom Bar (Quit) ---
                AppButton(icon: "power", title: "Quit Insomnia") {
                    NSApplication.shared.terminate(nil)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 300) // Width is fixed, height is dynamic
        // No .frame(height: ...) here! It will shrink to fit.
    }

}

// MARK: - Status Display View

struct StatusDisplayView: View {
    let isActive: Bool
    let secondsRemaining: Int
    let timeRemainingDisplay: String

    var body: some View {
        VStack(spacing: 4) {
            if isActive {
                Text("Staying Awake")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)

                Group {
                    if secondsRemaining == -1 {
                        Image(systemName: "infinity")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.white)
                    } else {
                        Text(timeRemainingDisplay)
                            .font(.system(size: 38, weight: .light, design: .monospaced))
                            .foregroundColor(.white)
                            .contentTransition(.numericText(countsDown: true))
                            .animation(.default, value: timeRemainingDisplay)
                    }
                }
                .frame(height: 50)
            } else {
                Text("System Normal")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))

                Text("Select a duration")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(height: 80) // Fixed height for status area to prevent jumping
        .padding(.top, 10)
    }
}

// MARK: - Custom Time Input View

struct CustomTimeInputView: View {
    @Binding var showCustomTime: Bool
    @Binding var customMinutes: String
    let onStart: (Int) -> Void

    var body: some View {
        Group {
            if showCustomTime {
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "timer")
                        TextField("Minutes", text: $customMinutes)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 60)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)

                    Button(action: {
                        if let mins = Int(customMinutes), mins > 0 {
                            onStart(mins)
                            showCustomTime = false
                            customMinutes = ""
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .frame(width: 36)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        showCustomTime = false
                        customMinutes = ""
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .frame(width: 36)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.8), Color.red.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            } else {
                AppButton(icon: "timer", title: "Custom Time") {
                    showCustomTime = true
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ContentView()
}
