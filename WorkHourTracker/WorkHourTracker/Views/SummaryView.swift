//
//  SummaryView.swift
//  WorkHourTracker
//
//  Pure presentation: shows the day's total, status, and a progress bar
//  toward the 10h legal limit. Receives only formatted values, so it's
//  fully decoupled from calculation logic.
//

import SwiftUI

struct SummaryView: View {
    let total: String
    let status: WorkDayStatus
    let progress: Double
    let minimumLabel: String
    let maximumLabel: String

    var body: some View {
        VStack(spacing: AppSpacing.m) {
            VStack(spacing: AppSpacing.xs) {
                Text("Total worked today")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
                Text(total)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppPalette.color(for: status))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: total)
            }

            statusBadge

            progressBar
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .fill(AppPalette.cardBackground)
        )
    }

    // MARK: - Subviews

    private var statusBadge: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: AppPalette.icon(for: status))
                .foregroundStyle(AppPalette.color(for: status))
            VStack(alignment: .leading, spacing: 2) {
                Text(status.title)
                    .font(AppTypography.headline)
                Text(status.detail)
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                .fill(AppPalette.color(for: status).opacity(0.12))
        )
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ProgressView(value: progress)
                .tint(AppPalette.color(for: status))
                .animation(.easeOut(duration: 0.25), value: progress)

            HStack {
                Text("Min \(minimumLabel)")
                Spacer()
                Text("Max \(maximumLabel)")
            }
            .font(AppTypography.caption)
            .foregroundStyle(.secondary)
        }
    }
}
