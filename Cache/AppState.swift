import AppKit
import Combine

final class AppState: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var showSettings: Bool = false
    @Published var showAccessibilityWarning: Bool = false
    @Published var shouldFocusSearch: Bool = false

    let store: ClipboardStore
    let preferences: PreferencesStore
    let accessibility: AccessibilityManager

    private let monitor: ClipboardMonitor
    private let hotkeyManager: HotkeyManager
    private let pasteService: PasteService
    private weak var statusBarController: StatusBarController?
    private var cancellables: Set<AnyCancellable> = []
    private var lastFrontmostApp: NSRunningApplication?

    init() {
        self.store = ClipboardStore()
        self.preferences = PreferencesStore()
        self.accessibility = AccessibilityManager()
        self.monitor = ClipboardMonitor(store: store)
        self.hotkeyManager = HotkeyManager()
        self.pasteService = PasteService()

        store.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func attachStatusBar(_ controller: StatusBarController) {
        self.statusBarController = controller
    }

    func start() {
        monitor.start()
        registerHotkey()
    }

    func registerHotkey() {
        hotkeyManager.register(hotkey: preferences.hotkey) { [weak self] in
            DispatchQueue.main.async {
                self?.togglePopover()
            }
        }
    }

    func updateHotkey(_ hotkey: Hotkey) {
        preferences.hotkey = hotkey
        registerHotkey()
    }

    func togglePopover() {
        statusBarController?.togglePopover()
    }

    func copyItem(_ item: ClipboardItem) {
        pasteService.copyToPasteboard(item.text)
    }

    func togglePin(_ item: ClipboardItem) {
        store.togglePinned(itemID: item.id)
    }

    func pasteItem(_ item: ClipboardItem) {
        pasteService.copyToPasteboard(item.text)

        if accessibility.isTrusted(prompt: false) {
            statusBarController?.closePopover()
            let appToActivate = lastFrontmostApp
            appToActivate?.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.pasteService.simulatePaste()
            }
        } else {
            showAccessibilityWarning = true
        }
    }

    func recordFrontmostApp() {
        lastFrontmostApp = NSWorkspace.shared.frontmostApplication
    }
}
