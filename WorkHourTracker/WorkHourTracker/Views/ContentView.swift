//
//  ContentView.swift
//  WorkHourTracker
//
//  Top-level screen. Pure View: it observes a WorkDayViewModel and
//  forwards user intents back to it. Knows nothing about SwiftData
//  beyond pulling the ModelContext from the environment to bootstrap
//  the ViewModel.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WorkDayViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.l) {
                    SummaryView(
                        total: viewModel.formattedTotal,
                        status: viewModel.status,
                        progress: viewModel.progress,
                        minimumLabel: viewModel.minimumLabel,
                        maximumLabel: viewModel.maximumLabel
                    )

                    intervalsSection

                    addIntervalButton

                    legalNotice
                }
                .padding(AppSpacing.m)
            }
            .background(AppPalette.screenBackground.ignoresSafeArea())
            .navigationTitle("Work Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Work Hours")
                            .font(AppTypography.headline)
                        Text(viewModel.todaysDate, format: .dateTime.weekday().day().month())
                            .font(AppTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.bootstrap(modelContext: modelContext)
        }
    }

    // MARK: - Sections

    private var intervalsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            Text("Intervals")
                .font(AppTypography.title)
                .padding(.horizontal, AppSpacing.xs)

            VStack(spacing: AppSpacing.m) {
                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                    TimeEntryRowView(
                        entry: entry,
                        index: index,
                        onClockInChange: { newValue in
                            viewModel.updateClockIn(for: entry, to: newValue)
                        },
                        onClockOutChange: { newValue in
                            viewModel.updateClockOut(for: entry, to: newValue)
                        },
                        onRemove: viewModel.canRemoveEntries
                            ? { viewModel.removeEntry(entry) }
                            : nil
                    )
                }
            }
        }
    }

    private var addIntervalButton: some View {
        Button {
            viewModel.addEntry()
        } label: {
            Label("Add interval", systemImage: "plus.circle.fill")
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.s)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var legalNotice: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label("Brazilian working hours", systemImage: "info.circle")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
            Text("Standard day: \(viewModel.minimumLabel) · Legal cap: \(viewModel.maximumLabel) (overtime included).")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkDay.self, TimeEntry.self], inMemory: true)
}
