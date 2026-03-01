//
//  HomeView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var sleepTimer: SleepTimer

    // Local UI state
    @State private var showCustomTime = false
    @State private var customMinutes: String = ""
    @State private var showUntilTime = false
    @State private var targetTime: Date = Date().addingTimeInterval(3600) // Default: 1 hour from now

    // Grid layout for buttons
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            // --- 1. Main Status Area ---
            StatusDisplayView(
                isActive: sleepTimer.isActive,
                isIndefinite: sleepTimer.isIndefinite,
                timeRemainingDisplay: sleepTimer.timeRemainingDisplay
            )

            Divider()
                .background(AppColors.subtleOverlay)
                .padding(.horizontal)
                .padding(.top, Spacing.medium)
                .padding(.bottom, Spacing.extraLarge)

            // --- 2. Duration Selection ---
            Text("Keep Awake For")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.primaryText)
                .textCase(.uppercase)
                .padding(.bottom, Spacing.small)

            LazyVGrid(columns: columns, spacing: Spacing.small) {
                AppButton(icon: "10.circle", title: "10 Min") { sleepTimer.start(minutes: 10) }
                AppButton(icon: "30.circle", title: "30 Min") { sleepTimer.start(minutes: 30) }
                AppButton(icon: "clock", title: "1 Hour") { sleepTimer.start(minutes: 60) }
                AppButton(icon: "infinity", title: "Indefinite") {
                    sleepTimer.start(minutes: -1)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, Spacing.small)

            // --- 3. Custom Time Input ---
            CustomTimeInputView(
                showCustomTime: $showCustomTime,
                customMinutes: $customMinutes,
                onStart: { minutes in
                    sleepTimer.start(minutes: minutes)
                    showUntilTime = false
                }
            )

            // --- 4. Until Time Picker ---
            UntilTimeInputView(
                showUntilTime: $showUntilTime,
                targetTime: $targetTime,
                onStart: { time in
                    sleepTimer.start(until: time)
                    showCustomTime = false
                }
            )

            Spacer(minLength: Spacing.extraLarge)

            // --- 5. Footer ---
            if sleepTimer.isActive {
                AppButton(icon: "bed.double.fill", title: "Allow Sleep", style: .destructive) {
                    sleepTimer.stop()
                }
                .padding(.horizontal)
                .padding(.bottom, Spacing.small)
            }

            // --- 6. Bottom Bar (Quit) ---
            AppButton(icon: "power", title: "Quit Insomnia") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal)
            .padding(.bottom, Spacing.medium)
        }
    }
}

// MARK: - Status Display View

struct StatusDisplayView: View {
    let isActive: Bool
    let isIndefinite: Bool
    let timeRemainingDisplay: String

    var body: some View {
        VStack(spacing: 4) {
            if isActive {
                Text("Staying Awake")
                    .font(.caption)
                    .foregroundColor(AppColors.primaryText)
                    .textCase(.uppercase)

                Group {
                    if isIndefinite {
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
                .frame(height: AppDimensions.countdownHeight)
            } else {
                Text("System Normal")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.emphasizedText)

                Text("Select a duration")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(height: AppDimensions.statusAreaHeight)
        .padding(.top, Spacing.medium)
    }
}

// MARK: - Custom Time Input View

struct CustomTimeInputView: View {
    @Binding var showCustomTime: Bool
    @Binding var customMinutes: String
    let onStart: (Int) -> Void

    var body: some View {
        TimePickerView(
            collapsedIcon: "timer",
            collapsedTitle: "Custom Time",
            fieldIcon: "timer",
            fieldPlaceholder: "Minutes",
            fieldText: $customMinutes,
            fieldFont: .system(size: 14),
            onFieldChange: { _, new in
                let digits = new.filter(\.isNumber)
                let clamped = Int(digits).map { min($0, 999) }
                return clamped.map { "\($0)" } ?? digits
            },
            stepperDeltas: [-30, -15, -5, +5, +15, +30],
            separatorAfterDelta: -5,
            onStepper: { delta in
                let current = Int(customMinutes) ?? 0
                let updated = max(1, min(999, current + delta))
                customMinutes = "\(updated)"
            },
            onConfirm: {
                if let mins = Int(customMinutes), mins > 0 {
                    onStart(mins)
                    showCustomTime = false
                    customMinutes = ""
                }
            },
            onCancel: {
                showCustomTime = false
                customMinutes = ""
            },
            isExpanded: $showCustomTime
        )
    }
}

// MARK: - Until Time Input View

struct UntilTimeInputView: View {
    @Binding var showUntilTime: Bool
    @Binding var targetTime: Date
    let onStart: (Date) -> Void

    @State private var timeText: String = ""

    var body: some View {
        TimePickerView(
            collapsedIcon: "clock.badge.checkmark",
            collapsedTitle: "Until Time",
            fieldIcon: "clock.badge.checkmark",
            fieldPlaceholder: "HH:MM AM",
            fieldText: $timeText,
            fieldFont: .system(size: 14, design: .monospaced),
            onFieldChange: { old, new in
                TimeInputUtil.validateTimeInput(oldValue: old, newValue: new)
            },
            stepperDeltas: [-60, -30, -15, +15, +30, +60],
            separatorAfterDelta: -15,
            onStepper: { delta in
                let base = TimeInputUtil.parseTime(from: timeText) ?? Date().addingTimeInterval(3600)
                let shifted = base.addingTimeInterval(Double(delta) * 60)
                let earliest = Date().addingTimeInterval(60)
                timeText = TimeInputUtil.formatTime(from: max(shifted, earliest))
            },
            onConfirm: {
                if let parsedTime = TimeInputUtil.parseTime(from: timeText) {
                    onStart(parsedTime)
                    showUntilTime = false
                }
            },
            onCancel: {
                showUntilTime = false
                timeText = ""
            },
            isExpanded: $showUntilTime,
            onExpand: {
                timeText = TimeInputUtil.oneHourFromNow()
            }
        )
        .padding(.top, Spacing.small)
    }
}

#Preview {
    ZStack {
        BackgroundGradientView()
        HomeView(sleepTimer: SleepTimer())
    }
    .frame(width: AppDimensions.windowWidth)
}
