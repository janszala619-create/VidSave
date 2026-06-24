import Photos
import Foundation

class PhotoLibraryService {
    static let shared = PhotoLibraryService()

    func requestPermissionIfNeeded() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized || status == .limited { return true }
        let result = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return result == .authorized || result == .limited
    }

    func saveVideo(at url: URL) async throws {
        guard await requestPermissionIfNeeded() else {
            throw NSError(domain: "PhotoLibrary", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Kein Zugriff auf die Galerie"])
        }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
}