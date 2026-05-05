# WorkHourTracker

A small native SwiftUI iOS app that helps you track how much time you've worked in a day, against the Brazilian CLT reference of **8h standard / 10h legal maximum** (8h regular + up to 2h overtime).

## Features

- Pure SwiftUI, native components only (no third-party libraries).
- **6 time inputs by default** (3 in/out interval pairs) — and you can add more.
- Live total, status (insufficient / standard / overtime / exceeded) and progress bar against the 10h cap.
- **SwiftData persistence**: each day is saved automatically.
- The first time you open a new day, the app pre-fills the previous day's schedule, so you don't retype the same hours every morning.

## Architecture

```
WorkHourTracker/
├── WorkHourTrackerApp.swift     // Entry point + ModelContainer
├── Models/
│   ├── WorkDay.swift            // @Model: a date + intervals
│   └── TimeEntry.swift          // @Model: a single in/out pair
├── Services/
│   ├── TimeCalculatorService.swift  // Protocol + default impl (rules, formatting)
│   └── WorkDayRepository.swift      // Protocol + SwiftData repo
├── ViewModels/
│   └── WorkDayViewModel.swift   // @Observable, MVVM, depends on protocols
├── Views/
│   ├── ContentView.swift        // Screen
│   ├── SummaryView.swift        // Total + status + progress
│   └── TimeEntryRowView.swift   // Reusable interval card
└── DesignSystem/
    └── AppTheme.swift           // Spacing, radius, typography, palette
```

### SOLID notes

- **S**ingle Responsibility: Models hold data, services compute, repository persists, ViewModel orchestrates, Views render.
- **O**pen/Closed: Status / palette / typography are enums you extend without touching call sites.
- **L**iskov: `TimeCalculatorServicing` and `WorkDayRepositoring` can be replaced by any conforming type (e.g. fakes for tests).
- **I**nterface Segregation: Two narrow protocols instead of one fat "AppService".
- **D**ependency Inversion: ViewModel depends on protocols, not concrete SwiftData / formatter classes.

### Patterns used

- **MVVM** — `WorkDayViewModel` uses `@Observable` (Swift 5.9 / iOS 17+).
- **Repository** — `WorkDayRepository` hides `ModelContext` / `FetchDescriptor` from callers.
- **Strategy / Dependency Injection** — calculator and repository injected via initializer.

## Requirements

- Xcode 15+
- iOS 17.0+ (SwiftData and `@Observable` minimum)

## How to run

1. Unzip the archive.
2. Open `WorkHourTracker.xcodeproj` in Xcode.
3. Pick an iOS 17+ simulator (or your device).
4. ⌘R.
