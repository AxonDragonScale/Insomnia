//
//  ContentView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct ContentView: View {
    // State variables
    @State private var isBlockingSleep = false
    @State private var timeRemaining: String = "00:00" // We will animate this later
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
            LinearGradient(
                colors: [
                    Color.indigo,
                    Color.indigo.opacity(0.8),
                    Color.purple.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // --- 1. Branding Header ---
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
                        .fill(isBlockingSleep ? Color.green : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .shadow(radius: isBlockingSleep ? 2 : 0)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)

                // --- 2. Main Status Area ---
                VStack(spacing: 4) {
                    if isBlockingSleep {
                        Text("Staying Awake")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .textCase(.uppercase)

                        Group {
                            if timeRemaining == "∞" {
                                Image(systemName: "infinity")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.white)
                            } else {
                                Text(timeRemaining)
                                    .font(.system(size: 38, weight: .light, design: .monospaced))
                                    .foregroundColor(.white)
                                    .contentTransition(.numericText(countsDown: true))
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
                    DurationButton(title: "10 Min", icon: "10.circle") { activate(min: 10) }
                    DurationButton(title: "30 Min", icon: "30.circle") { activate(min: 30) }
                    DurationButton(title: "1 Hour", icon: "clock") { activate(min: 60) }
                    DurationButton(title: "Indefinite", icon: "infinity") { activate(min: -1) }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // --- 4. Custom Time Input ---
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
                                activate(min: mins)
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
                    .padding(.bottom, 10)
                } else {
                    Button(action: { showCustomTime = true }) {
                        HStack {
                            Image(systemName: "timer")
                            Text("Custom Time")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                // --- 4. Footer ---
                if isBlockingSleep {
                    Button(action: stop) {
                        HStack {
                            Image(systemName: "bed.double.fill")
                            Text("Allow Sleep")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.8), Color.red.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding([.horizontal])
                    .padding(.top, 8)
                }

                Spacer(minLength: 24)

                // Bottom Bar (Quit)
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit Insomnia")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 260) // Width is fixed, height is dynamic
        // No .frame(height: ...) here! It will shrink to fit.
    }

    // --- Helper Logic Stubs ---
    func activate(min: Int) {
        isBlockingSleep = true
        timeRemaining = min == -1 ? "∞" : "\(min):00"
    }

    func stop() {
        isBlockingSleep = false
    }
}

// Custom Button Component to keep code clean
struct DurationButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity) // Fill the grid cell
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
