//
//  TimeCalculatorService.swift
//  WorkHourTracker
//
//  All "how long did I work" logic lives behind a protocol so the
//  ViewModel depends on an abstraction (Dependency Inversion) and
//  can be unit-tested with a fake implementation.
//
//  Brazilian CLT reference values used here:
//    - 8h  = standard daily working hours
//    - 10h = legal maximum (8h normal + 2h overtime)
//

import Foundation

// MARK: - Status

/// High-level classification of a working day used by the UI layer
/// to decide colors, copy and warnings.
enum WorkDayStatus: Equatable {
    case insufficient   // < 8h
    case standard       // ~ 8h
    case overtime       // > 8h and <= 10h
    case exceeded       // > 10h

    var title: String {
        switch self {
        case .insufficient: return "Below the 8h minimum"
        case .standard:     return "Standard working day"
        case .overtime:     return "Overtime (within legal limit)"
        case .exceeded:     return "Above the 10h legal limit"
        }
    }

    var detail: String {
        switch self {
        case .insufficient: return "You still need to log more time to reach 8h."
        case .standard:     return "You've completed the regular Brazilian working day."
        case .overtime:     return "You're in overtime territory — keep an eye on the 10h cap."
        case .exceeded:     return "You've gone past the 10h legal maximum for the day."
        }
    }
}

// MARK: - Protocol

protocol TimeCalculatorServicing {
    var minimumSeconds: TimeInterval { get }
    var maximumSeconds: TimeInterval { get }

    func totalWorkedSeconds(for entries: [TimeEntry]) -> TimeInterval
    func formattedDuration(_ seconds: TimeInterval) -> String
    func status(for seconds: TimeInterval) -> WorkDayStatus
    func progress(for seconds: TimeInterval) -> Double
}

// MARK: - Default implementation

struct TimeCalculatorService: TimeCalculatorServicing {
    let minimumSeconds: TimeInterval = 8 * 3600
    let maximumSeconds: TimeInterval = 10 * 3600

    func totalWorkedSeconds(for entries: [TimeEntry]) -> TimeInterval {
        entries.reduce(0) { partial, entry in
            partial + entry.duration
        }
    }

    func formattedDuration(_ seconds: TimeInterval) -> String {
        let total   = max(0, Int(seconds.rounded()))
        let hours   = total / 3600
        let minutes = (total % 3600) / 60
        return String(format: "%02dh %02dmin", hours, minutes)
    }

    func status(for seconds: TimeInterval) -> WorkDayStatus {
        // 1 minute tolerance around the standard 8h mark.
        let tolerance: TimeInterval = 60

        if seconds < minimumSeconds - tolerance { return .insufficient }
        if seconds <= minimumSeconds + tolerance { return .standard }
        if seconds <= maximumSeconds { return .overtime }
        return .exceeded
    }

    /// 0...1 progress against the legal maximum. Useful for progress bars.
    func progress(for seconds: TimeInterval) -> Double {
        guard maximumSeconds > 0 else { return 0 }
        return min(1.0, max(0.0, seconds / maximumSeconds))
    }
}
