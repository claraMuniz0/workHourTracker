//
//  TimeEntry.swift
//  WorkHourTracker
//
//  SwiftData model for a single clock-in / clock-out interval.
//  Pairs of these entries belong to a WorkDay.
//

import Foundation
import SwiftData

@Model
final class TimeEntry {
    @Attribute(.unique) var id: UUID
    var clockIn: Date
    var clockOut: Date
    var order: Int
    var workDay: WorkDay?

    init(clockIn: Date, clockOut: Date, order: Int = 0) {
        self.id = UUID()
        self.clockIn = clockIn
        self.clockOut = clockOut
        self.order = order
    }

    /// Duration of this interval (clamped to non-negative values).
    var duration: TimeInterval {
        max(0, clockOut.timeIntervalSince(clockIn))
    }
}
