//
//  WorkDay.swift
//  WorkHourTracker
//
//  SwiftData model representing one working day (a date plus its intervals).
//  Single Responsibility: it only knows how to describe a day; all rules live
//  in dedicated services.
//

import Foundation
import SwiftData

@Model
final class WorkDay {
    @Attribute(.unique) var id: UUID
    var date: Date

    // Cascade delete so removing a day removes its intervals.
    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.workDay)
    var entries: [TimeEntry]

    init(date: Date = Date(), entries: [TimeEntry] = []) {
        self.id = UUID()
        self.date = date
        self.entries = entries
    }
}
