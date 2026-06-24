import SwiftUI

struct HistoryView: View {
    @ObservedObject var vm = HistoryViewModel.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if vm.entries.isEmpty {
                    ContentUnavailableView(
                        "Kein Verlauf",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Heruntergeladene Videos erscheinen hier.")
                    )
                } else {
                    List {
                        ForEach(vm.entries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                HStack {
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: entry.status == .completed
                                          ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(entry.status == .completed ? .green : .red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Verlauf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Schliessen") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !vm.entries.isEmpty {
                        Button("Loeschen", role: .destructive) { vm.clearHistory() }
                    }
                }
            }
        }
    }
}