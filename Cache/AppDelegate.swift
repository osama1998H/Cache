import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = StatusBarController(appState: appState)
        statusBarController = controller
        appState.attachStatusBar(controller)
        appState.start()
    }
}
