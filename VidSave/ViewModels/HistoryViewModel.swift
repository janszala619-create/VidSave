import Foundation

class HistoryViewModel: ObservableObject {
    static let shared = HistoryViewModel()

    @Published var entries: [DownloadEntry] = []
    private let key = "downloadHistory"

    init() { load() }

    func addEntry(_ entry: DownloadEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func clearHistory() {
        entries = []
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([DownloadEntry].self, from: data)
        else { return }
        entries = decoded
    }
}