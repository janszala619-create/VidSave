import SwiftUI

struct DownloadView: View {
    @ObservedObject var vm: DownloadViewModel
    let info: VideoInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: URL(string: info.thumbnailURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.secondary.opacity(0.2))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(info.title)
                .font(.headline)
                .lineLimit(2)
            if !info.formats.isEmpty {
                Picker("Qualitaet", selection: $vm.selectedFormat) {
                    ForEach(info.formats) { format in
                        Text(format.label).tag(Optional(format))
                    }
                }
                .pickerStyle(.segmented)
            }
            Button {
                Task { await vm.downloadVideo() }
            } label: {
                Group {
                    if vm.isDownloading {
                        ProgressView().tint(.white)
                    } else {
                        Label("In Galerie speichern", systemImage: "arrow.down.to.line")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(vm.isDownloading || vm.selectedFormat == nil)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}