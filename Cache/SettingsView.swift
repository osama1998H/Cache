import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    var onInvalidHotkey: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title3)

            VStack(alignment: .leading, spacing: 8) {
                Text("Hotkey")
                    .font(.headline)
                HotkeyRecorderView(hotkey: Binding(
                    get: { appState.preferences.hotkey },
                    set: { appState.updateHotkey($0) }
                ), onInvalidHotkey: onInvalidHotkey)
                Text("Must include Cmd or Option.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Accessibility")
                    .font(.headline)
                Text("Enable Accessibility to allow automatic paste into the frontmost app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("Open Accessibility Settings") {
                    appState.accessibility.openSystemSettings()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Privacy")
                    .font(.headline)
                Text("Clipboard history is stored in memory only and cleared on quit.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 360, height: 320)
    }
}
