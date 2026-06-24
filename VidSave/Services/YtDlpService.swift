import Foundation

class YtDlpService {
    static let shared = YtDlpService()

    private var serverURL: String {
        UserDefaults.standard.string(forKey: "serverURL") ?? "http://localhost:8000"
    }

    func fetchInfo(for url: String) async throws -> VideoInfo {
        guard let endpoint = URL(string: "\(serverURL)/info") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["url": url])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(VideoInfo.self, from: data)
    }

    func downloadVideo(url: String, formatID: String) async throws -> URL {
        guard let endpoint = URL(string: "\(serverURL)/download") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["url": url, "format_id": formatID])
        let (localURL, _) = try await URLSession.shared.download(for: request)
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        try FileManager.default.moveItem(at: localURL, to: destination)
        return destination
    }
}