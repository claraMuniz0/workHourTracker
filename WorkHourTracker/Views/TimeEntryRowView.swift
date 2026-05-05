//
//  TimeEntryRowView.swift
//  WorkHourTracker
//
//  Reusable card showing a single in/out interval.
//  Uses native DatePicker (.hourAndMinute) — no third-party UI.
//
//  The row receives change closures rather than mutating the model
//  directly, so it stays decoupled from persistence (Single Responsibility).
//

import SwiftUI

struct TimeEntryRowView: View {
    let entry: TimeEntry
    let index: Int
    let onClockInChange: (Date) -> Void
    let onClockOutChange: (Date) -> Void
    let onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            header

            HStack(spacing: AppSpacing.m) {
                TimeField(
                    title: "Clock in",
                    systemImage: "arrow.right.to.line",
                    date: Binding(
                        get: { entry.clockIn },
                        set: { onClockInChange($0) }
                    )
                )

                TimeField(
                    title: "Clock out",
                    systemImage: "arrow.left.to.line",
                    date: Binding(
                        get: { entry.clockOut },
                        set: { onClockOutChange($0) }
                    )
                )
            }

            durationLabel
        }
        .appCard()
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("Interval \(index + 1)")
                .font(AppTypography.title)
            Spacer()
            if let onRemove {
                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "trash")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove interval \(index + 1)")
            }
        }
    }

    private var durationLabel: some View {
        let invalid = entry.clockOut <= entry.clockIn
        return HStack(spacing: AppSpacing.xs) {
            Image(systemName: invalid ? "exclamationmark.triangle.fill" : "clock")
                .foregroundStyle(invalid ? .orange : .secondary)
            Text(invalid
                 ? "Clock-out must be after clock-in"
                 : "Duration: \(formatted(entry.duration))")
                .font(AppTypography.caption)
                .foregroundStyle(invalid ? .orange : .secondary)
        }
    }

    private func formatted(_ seconds: TimeInterval) -> String {
        let total   = max(0, Int(seconds.rounded()))
        let hours   = total / 3600
        let minutes = (total % 3600) / 60
        return String(format: "%02dh %02dmin", hours, minutes)
    }
}

// MARK: - Field component

private struct TimeField: View {
    let title: String
    let systemImage: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(title, systemImage: systemImage)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            DatePicker(
                "",
                selection: $date,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
