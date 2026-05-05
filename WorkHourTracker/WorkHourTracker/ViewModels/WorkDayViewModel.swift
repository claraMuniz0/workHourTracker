//
//  WorkDayViewModel.swift
//  WorkHourTracker
//
//  MVVM: this ViewModel exposes display-ready state and intent methods
//  to ContentView. It depends on:
//    - WorkDayRepositoring  (persistence)
//    - TimeCalculatorServicing (rules / formatting)
//
//  Both are protocols, so the View layer never reaches into SwiftData
//  directly and tests can substitute fakes.
//

import Foundation
import SwiftData
import Observation

@Observable
final class WorkDayViewModel {

    // MARK: - Public state

    private(set) var entries: [TimeEntry] = []
    private(set) var todaysDate: Date = Date()

    // MARK: - Dependencies (DI via initializer)

    private let calculator: TimeCalculatorServicing

    // The repository is created once we receive a ModelContext from the View.
    private var repository: WorkDayRepositoring?
    private var currentWorkDay: WorkDay?

    // MARK: - Init

    init(calculator: TimeCalculatorServicing = TimeCalculatorService()) {
        self.calculator = calculator
    }

    // MARK: - Lifecycle

    /// Called by the view once the SwiftData ModelContext is available.
    func bootstrap(modelContext: ModelContext) {
        let repo = WorkDayRepository(context: modelContext)
        self.repository = repo
        loadOrCreateToday(using: repo)
    }

    // MARK: - Derived values for the UI

    var totalSeconds: TimeInterval {
        calculator.totalWorkedSeconds(for: entries)
    }

    var formattedTotal: String {
        calculator.formattedDuration(totalSeconds)
    }

    var status: WorkDayStatus {
        calculator.status(for: totalSeconds)
    }

    var progress: Double {
        calculator.progress(for: totalSeconds)
    }

    var minimumLabel: String {
        calculator.formattedDuration(calculator.minimumSeconds)
    }

    var maximumLabel: String {
        calculator.formattedDuration(calculator.maximumSeconds)
    }

    var canRemoveEntries: Bool {
        // Keep at least 3 pairs (= 6 in/out inputs), per the requirement.
        entries.count > 2
    }

    // MARK: - Intents

    func addEntry() {
        guard let repository, let day = currentWorkDay else { return }

        let lastOut = entries.last?.clockOut ?? Date()
        let proposedIn  = lastOut
        let proposedOut = lastOut.addingTimeInterval(3600) // +1h default

        let entry = TimeEntry(
            clockIn: proposedIn,
            clockOut: proposedOut,
            order: entries.count
        )
        entry.workDay = day
        repository.insert(entry)
        day.entries.append(entry)
        entries.append(entry)
        persist()
    }

    func removeEntry(_ entry: TimeEntry) {
        guard let repository, canRemoveEntries else { return }
        repository.delete(entry)
        entries.removeAll { $0.id == entry.id }
        currentWorkDay?.entries.removeAll { $0.id == entry.id }
        // Re-index remaining entries.
        for (index, existing) in entries.enumerated() {
            existing.order = index
        }
        persist()
    }

    func updateClockIn(for entry: TimeEntry, to newValue: Date) {
        entry.clockIn = newValue
        persist()
    }

    func updateClockOut(for entry: TimeEntry, to newValue: Date) {
        entry.clockOut = newValue
        persist()
    }

    // MARK: - Private

    private func persist() {
        try? repository?.save()
    }

    private func loadOrCreateToday(using repository: WorkDayRepositoring) {
        let today = Calendar.current.startOfDay(for: Date())
        todaysDate = today

        do {
            if let existing = try repository.todayWorkDay() {
                currentWorkDay = existing
                entries = existing.entries.sorted { $0.order < $1.order }
                return
            }

            // No record for today yet — create one, seeding from the most
            // recent previous day so the user doesn't retype yesterday's
            // schedule (this is the "remember" requirement).
            let newDay = WorkDay(date: today)
            repository.insert(newDay)

            let previousDay = try repository.previousWorkDay(before: today)
            let seedEntries = makeSeedEntries(forDate: today, basedOn: previousDay)
            for entry in seedEntries {
                entry.workDay = newDay
                repository.insert(entry)
                newDay.entries.append(entry)
            }
            currentWorkDay = newDay
            entries = newDay.entries.sorted { $0.order < $1.order }
            try repository.save()
        } catch {
            // Fall back to a pristine in-memory day so the UI can still render.
            let fallback = WorkDay(date: today)
            currentWorkDay = fallback
            entries = makeSeedEntries(forDate: today, basedOn: nil)
        }
    }

    /// Builds the initial 3 in/out pairs (= 6 inputs) for a brand new day.
    /// If `basedOn` has entries, copies their hours-of-day onto `date`.
    private func makeSeedEntries(forDate date: Date, basedOn previous: WorkDay?) -> [TimeEntry] {
        if let previous, !previous.entries.isEmpty {
            return previous.entries
                .sorted { $0.order < $1.order }
                .enumerated()
                .map { index, entry in
                    TimeEntry(
                        clockIn: combine(date: date, time: entry.clockIn),
                        clockOut: combine(date: date, time: entry.clockOut),
                        order: index
                    )
                }
        }

        // Sensible default: 08:00–12:00, 13:00–17:00, 17:00–18:00
        let defaults: [(inH: Int, inM: Int, outH: Int, outM: Int)] = [
            (8, 0, 12, 0),
            (13, 0, 17, 0),
            (17, 0, 18, 0)
        ]
        return defaults.enumerated().map { index, def in
            TimeEntry(
                clockIn:  makeTime(date, hour: def.inH,  minute: def.inM),
                clockOut: makeTime(date, hour: def.outH, minute: def.outM),
                order: index
            )
        }
    }

    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(
            bySettingHour: comps.hour ?? 0,
            minute: comps.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
    }

    private func makeTime(_ date: Date, hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        ) ?? date
    }
}
