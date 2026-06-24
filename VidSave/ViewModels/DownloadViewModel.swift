import Foundation
import SwiftUI

@MainActor
class DownloadViewModel: ObservableObject {
    @Published var urlInput = ""
    @Published var videoInfo: VideoInfo?
    @Published var selectedFormat: VideoFormat?
    @Published var isLoading = false
    @Published var isDownloading = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func fetchInfo() async {
        guard !urlInput.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        videoInfo = nil
        defer { isLoading = false }
        do {
            let info = try await YtDlpService.shared.fetchInfo(for: urlInput)
            videoInfo = info
            selectedFormat = info.formats.first
        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }
    }

    func downloadVideo() async {
        guard let info = videoInfo, let format = selectedFormat else { return }
        isDownloading = true
        errorMessage = nil
        successMessage = nil
        defer { isDownloading = false }
        do {
            let fileURL = try await YtDlpService.shared.downloadVideo(
                url: info.sourceURL,
                formatID: format.id
            )
            try await PhotoLibraryService.shared.saveVideo(at: fileURL)
            try? FileManager.default.removeItem(at: fileURL)
            successMessage = "Video gespeichert!"
            HistoryViewModel.shared.addEntry(
                DownloadEntry(title: info.title, sourceURL: info.sourceURL, status: .completed)
            )
        } catch {
            errorMessage = "Download fehlgeschlagen: \(error.localizedDescription)"
            if let info = videoInfo {
                HistoryViewModel.shared.addEntry(
                    DownloadEntry(title: info.title, sourceURL: info.sourceURL, status: .failed)
                )
            }
        }
    }
}