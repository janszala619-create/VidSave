import Foundation

struct VideoInfo: Identifiable, Codable {
    let id: UUID
    let title: String
    let thumbnailURL: String
    let sourceURL: String
    let formats: [VideoFormat]

    init(id: UUID = UUID(), title: String, thumbnailURL: String, sourceURL: String, formats: [VideoFormat]) {
        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.sourceURL = sourceURL
        self.formats = formats
    }
}

struct VideoFormat: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let ext: String
}