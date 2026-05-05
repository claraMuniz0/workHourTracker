//
//  WorkDayRepository.swift
//  WorkHourTracker
//
//  Repository pattern: hides SwiftData details behind a protocol.
//  The ViewModel asks the repository for "today's day" and "the
//  most recent past day" — it doesn't know about FetchDescriptors.
//
//  This keeps the ViewModel free of persistence concerns (Single
//  Responsibility) and makes it trivial to swap the storage layer
//  later (Open/Closed + Dependency Inversion).
//

import Foundation
import SwiftData

protocol WorkDayRepositoring {
    func todayWorkDay() throws -> WorkDay?
    func previousWorkDay(before date: Date) throws -> WorkDay?
    func insert(_ workDay: WorkDay)
    func insert(_ entry: TimeEntry)
    func delete(_ entry: TimeEntry)
    func save() throws
}

struct WorkDayRepository: WorkDayRepositoring {
    let context: ModelContext

    func todayWorkDay() throws -> WorkDay? {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return nil
        }

        let predicate = #Predicate<WorkDay> { day in
            day.date >= startOfToday && day.date < startOfTomorrow
        }
        var descriptor = FetchDescriptor<WorkDay>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func previousWorkDay(before date: Date) throws -> WorkDay? {
        let startOfDate = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<WorkDay> { day in
            day.date < startOfDate
        }
        var descriptor = FetchDescriptor<WorkDay>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func insert(_ workDay: WorkDay) {
        context.insert(workDay)
    }

    func insert(_ entry: TimeEntry) {
        context.insert(entry)
    }

    func delete(_ entry: TimeEntry) {
        context.delete(entry)
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
