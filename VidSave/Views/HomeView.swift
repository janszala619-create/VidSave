import SwiftUI

struct HomeView: View {
    @StateObject private var vm = DownloadViewModel()
    @State private var showHistory = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    urlInputSection
                    if vm.isLoading {
                        ProgressView("Lade Video-Info...")
                            .padding()
                    }
                    if let info = vm.videoInfo {
                        DownloadView(vm: vm, info: info)
                    }
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    if let success = vm.successMessage {
                        Text(success)
                            .foregroundStyle(.green)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            .navigationTitle("VidSave")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showHistory = true } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showHistory) { HistoryView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var urlInputSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)
                TextField("Video-Link einfügen...", text: $vm.urlInput)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                if !vm.urlInput.isEmpty {
                    Button {
                        vm.urlInput = ""
                        vm.videoInfo = nil
                        vm.errorMessage = nil
                        vm.successMessage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                Task { await vm.fetchInfo() }
            } label: {
                Label("Video laden", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(vm.urlInput.isEmpty || vm.isLoading)
        }
    }
}