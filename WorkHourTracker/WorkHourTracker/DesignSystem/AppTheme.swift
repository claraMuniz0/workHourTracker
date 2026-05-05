//
//  AppTheme.swift
//  WorkHourTracker
//
//  Lightweight design system: spacing, radius, typography and a small
//  semantic palette built only on native SwiftUI / SF Symbols.
//
//  Centralizing these values keeps Views consistent and makes future
//  visual tweaks a single-file change (Open/Closed in spirit).
//

import SwiftUI

enum AppSpacing {
    static let xs: CGFloat = 4
    static let s:  CGFloat = 8
    static let m:  CGFloat = 16
    static let l:  CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppRadius {
    static let small:  CGFloat = 8
    static let medium: CGFloat = 12
    static let large:  CGFloat = 20
}

enum AppTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title      = Font.system(.title3,     design: .rounded, weight: .semibold)
    static let headline   = Font.system(.headline,   design: .rounded)
    static let body       = Font.system(.body,       design: .rounded)
    static let caption    = Font.system(.caption,    design: .rounded, weight: .medium)
}

enum AppPalette {
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let screenBackground = Color(.systemGroupedBackground)

    static func color(for status: WorkDayStatus) -> Color {
        switch status {
        case .insufficient: return .orange
        case .standard:     return .green
        case .overtime:     return .blue
        case .exceeded:     return .red
        }
    }

    static func icon(for status: WorkDayStatus) -> String {
        switch status {
        case .insufficient: return "hourglass"
        case .standard:     return "checkmark.seal.fill"
        case .overtime:     return "clock.badge.exclamationmark"
        case .exceeded:     return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Reusable card modifier

struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppPalette.cardBackground)
            )
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }
}
