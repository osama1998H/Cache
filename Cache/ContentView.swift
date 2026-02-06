import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    @State private var selection: ClipboardItem.ID?
    @FocusState private var searchFocused: Bool
    @State private var showInvalidHotkeyAlert = false

    private var filteredSections: (pinned: [ClipboardItem], recent: [ClipboardItem]) {
        appState.store.filteredSections(query: appState.searchQuery)
    }

    private var filteredItems: [ClipboardItem] {
        filteredSections.pinned + filteredSections.recent
    }

    var body: some View {
        VStack(spacing: 8) {
            header
            searchField
            listSection
            if appState.showAccessibilityWarning {
                accessibilityWarning
            }
            footer
            defaultActionButton
        }
        .frame(width: 360, height: 420)
        .padding(12)
        .onAppear { searchFocused = true }
        .onChange(of: appState.shouldFocusSearch) { newValue in
            if newValue {
                searchFocused = true
                appState.shouldFocusSearch = false
            }
        }
        .onChange(of: filteredItems.count) { _ in
            if let selection {
                if !filteredItems.contains(where: { $0.id == selection }) {
                    self.selection = filteredItems.first?.id
                }
            } else {
                selection = filteredItems.first?.id
            }
        }
        .onChange(of: appState.searchQuery) { _ in
            if let selection, !filteredItems.contains(where: { $0.id == selection }) {
                self.selection = filteredItems.first?.id
            }
        }
        .sheet(isPresented: $appState.showSettings) {
            SettingsView(onInvalidHotkey: { showInvalidHotkeyAlert = true })
                .environmentObject(appState)
        }
        .alert("Hotkey must include Cmd or Option", isPresented: $showInvalidHotkeyAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack {
            Text("Cache")
                .font(.headline)
            Spacer()
            Button {
                appState.showSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
    }

    private var searchField: some View {
        TextField("Search clipboard", text: $appState.searchQuery)
            .textFieldStyle(.roundedBorder)
            .focused($searchFocused)
    }

    private var listSection: some View {
        Group {
            if filteredItems.isEmpty {
                VStack {
                    Spacer()
                    Text("No clipboard items yet")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(selection: $selection) {
                    if !filteredSections.pinned.isEmpty {
                        Section("Pinned") {
                            ForEach(filteredSections.pinned) { item in
                                itemRow(item)
                            }
                        }
                    }
                    if !filteredSections.recent.isEmpty {
                        Section("Recent") {
                            ForEach(filteredSections.recent) { item in
                                itemRow(item)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listRowBackground(Color.clear)
            }
        }
    }

    private func itemRow(_ item: ClipboardItem) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .lineLimit(2)
                    .truncationMode(.tail)
                HStack(spacing: 8) {
                    Text(item.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if let appName = item.sourceAppName {
                        Text(appName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer(minLength: 8)

            Button {
                appState.togglePin(item)
            } label: {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(item.isPinned ? .orange : .secondary)
            }
            .buttonStyle(.plain)
            .help(item.isPinned ? "Unpin" : "Pin")
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(item.isPinned ? "Unpin" : "Pin") {
                appState.togglePin(item)
            }
            Button("Copy") {
                appState.copyItem(item)
            }
        }
        .onTapGesture(count: 2) {
            appState.pasteItem(item)
        }
    }

    private var accessibilityWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Enable Accessibility to allow paste.")
                .font(.caption)
            Spacer()
            Button("Open Settings") {
                appState.accessibility.openSystemSettings()
            }
            .buttonStyle(.link)
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(6)
    }

    private var footer: some View {
        HStack {
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.bordered)

            Spacer()
            Text("\(appState.store.recentCount)/\(appState.store.maxRecentItems) recent • \(appState.store.pinnedCount) pinned")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var defaultActionButton: some View {
        Button("") {
            pasteSelected()
        }
        .keyboardShortcut(.defaultAction)
        .opacity(0)
        .frame(width: 0, height: 0)
    }

    private func pasteSelected() {
        if let selection, let item = filteredItems.first(where: { $0.id == selection }) {
            appState.pasteItem(item)
        } else if let first = filteredItems.first {
            appState.pasteItem(first)
        }
    }
}
