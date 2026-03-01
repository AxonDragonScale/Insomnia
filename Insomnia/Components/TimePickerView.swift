//
//  TimePickerView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

// MARK: - TimePickerView

/// A shared expandable card used by both Custom Time and Until Time inputs.
///
/// Collapsed: renders as a standard `AppButton`.
/// Expanded: renders a single rounded card with two rows separated by a divider:
///   1. Icon + TextField + Confirm + Cancel
///   2. Stepper buttons (negative | positive), split by a separator at `separatorAfterDelta`
struct TimePickerView: View {

    // MARK: Collapsed state config
    let collapsedIcon: String
    let collapsedTitle: String

    // MARK: Text field config
    let fieldIcon: String
    let fieldPlaceholder: String
    @Binding var fieldText: String
    let fieldFont: Font
    let onFieldChange: (String, String) -> String   // (old, new) -> validated

    // MARK: Stepper config
    let stepperDeltas: [Int]
    let separatorAfterDelta: Int                    // insert separator after this delta value
    let onStepper: (Int) -> Void                    // called with the chosen delta

    // MARK: Actions
    let onConfirm: () -> Void
    let onCancel: () -> Void

    // MARK: Internal state
    @Binding var isExpanded: Bool
    var onExpand: (() -> Void)? = nil               // called just before expanding
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isExpanded {
                expandedCard
            } else {
                collapsedButton
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Collapsed

    private var collapsedButton: some View {
        AppButton(icon: collapsedIcon, title: collapsedTitle) {
            onExpand?()
            isExpanded = true
            isFocused = true
        }
    }

    // MARK: - Expanded Card

    private var expandedCard: some View {
        VStack(spacing: 0) {
            inputRow
            cardDivider
            stepperRow
        }
        .background(AppColors.backgroundOverlay)
        .cornerRadius(AppDimensions.cornerRadius)
    }

    // MARK: - Input Row

    private var inputRow: some View {
        HStack(spacing: Spacing.small) {
            HStack(spacing: Spacing.small) {
                Image(systemName: fieldIcon)
                    .foregroundColor(.white)
                TextField(fieldPlaceholder, text: $fieldText)
                    .onChange(of: fieldText) { old, new in
                        fieldText = onFieldChange(old, new)
                    }
                    .textFieldStyle(.plain)
                    .font(fieldFont)
                    .foregroundColor(.white)
                    .focused($isFocused)
                    .frame(width: 70)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HoverIconButton(icon: "checkmark", color: AppColors.confirmGreen, action: onConfirm)
            HoverIconButton(icon: "xmark", color: AppColors.rejectRed, action: onCancel)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.small)
    }

    // MARK: - Stepper Row

    private var stepperRow: some View {
        HStack(spacing: 0) {
            ForEach(stepperDeltas, id: \.self) { delta in
                StepperButton(delta: delta, onStepper: onStepper)

                if delta == separatorAfterDelta {
                    stepperSeparator
                }
            }
        }
        .padding(.vertical, Spacing.verySmall)
        .padding(.horizontal, Spacing.verySmall)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var stepperSeparator: some View {
        Rectangle()
            .fill(AppColors.subtleOverlay)
            .frame(width: 1)
            .padding(.vertical, Spacing.small)
            .padding(.horizontal, Spacing.small)
    }

    // MARK: - Card Divider

    private var cardDivider: some View {
        Rectangle()
            .fill(AppColors.subtleOverlay)
            .frame(height: 1)
            .padding(.horizontal, Spacing.small)
    }
}

// MARK: - HoverIconButton

private struct HoverIconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .padding(.horizontal, Spacing.verySmall)
                .background(
                    RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                        .fill(isHovered ? AppColors.subtleOverlay : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - StepperButton

private struct StepperButton: View {
    let delta: Int
    let onStepper: (Int) -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            onStepper(delta)
        } label: {
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                        .fill(isHovered ? AppColors.subtleOverlay : Color.clear)
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 2)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        BackgroundGradientView()
        VStack(spacing: Spacing.small) {

            // Custom Time - collapsed
            TimePickerView(
                collapsedIcon: "timer",
                collapsedTitle: "Custom Time",
                fieldIcon: "timer",
                fieldPlaceholder: "Minutes",
                fieldText: .constant(""),
                fieldFont: .system(size: 14),
                onFieldChange: { _, new in new },
                stepperDeltas: [-30, -15, -5, +5, +15, +30],
                separatorAfterDelta: -5,
                onStepper: { _ in },
                onConfirm: {},
                onCancel: {},
                isExpanded: .constant(false)
            )

            // Custom Time - expanded
            TimePickerView(
                collapsedIcon: "timer",
                collapsedTitle: "Custom Time",
                fieldIcon: "timer",
                fieldPlaceholder: "Minutes",
                fieldText: .constant("45"),
                fieldFont: .system(size: 14),
                onFieldChange: { _, new in new },
                stepperDeltas: [-30, -15, -5, +5, +15, +30],
                separatorAfterDelta: -5,
                onStepper: { _ in },
                onConfirm: {},
                onCancel: {},
                isExpanded: .constant(true)
            )

            // Until Time - expanded
            TimePickerView(
                collapsedIcon: "clock.badge.checkmark",
                collapsedTitle: "Until Time",
                fieldIcon: "clock.badge.checkmark",
                fieldPlaceholder: "HH:MM AM",
                fieldText: .constant("09:30 AM"),
                fieldFont: .system(size: 14, design: .monospaced),
                onFieldChange: { _, new in new },
                stepperDeltas: [-60, -30, -15, +15, +30, +60],
                separatorAfterDelta: -15,
                onStepper: { _ in },
                onConfirm: {},
                onCancel: {},
                isExpanded: .constant(true)
            )
        }
        .padding(.vertical)
    }
    .frame(width: AppDimensions.windowWidth)
}
