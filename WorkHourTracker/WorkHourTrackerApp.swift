//
//  WorkHourTrackerApp.swift
//  WorkHourTracker
//
//  App entry point. Wires up the SwiftData ModelContainer so the
//  whole view hierarchy can persist WorkDay / TimeEntry instances.
//

import SwiftUI
import SwiftData

@main
struct WorkHourTrackerApp: App {
    // The ModelContainer is the root persistence object for SwiftData.
    // Holding it as a property guarantees a single shared instance.
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: WorkDay.self, TimeEntry.self)
        } catch {
            fatalError("Failed to start SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
