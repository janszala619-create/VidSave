import Foundation

struct DownloadEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let sourceURL: String
    let date: Date
    var status: DownloadStatus

    enum DownloadStatus: String, Codable {
        case completed, failed
    }

    init(id: UUID = UUID(), title: String, sourceURL: String, date: Date = .now, status: DownloadStatus) {
        self.id = id
        self.title = title
        self.sourceURL = sourceURL
        self.date = date
        self.status = status
    }
}