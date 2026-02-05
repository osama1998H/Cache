import SwiftUI
import AppKit
import Carbon.HIToolbox

struct HotkeyRecorderView: View {
    @Binding var hotkey: Hotkey
    var onInvalidHotkey: (() -> Void)?

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        Button(isRecording ? "Recording..." : hotkey.displayString) {
            toggleRecording()
        }
        .buttonStyle(.bordered)
        .onDisappear { stopRecording() }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let modifiers = Hotkey.carbonModifiers(from: flags)

            let hasCmdOrOption = modifiers & UInt32(cmdKey | optionKey) != 0
            guard hasCmdOrOption else {
                onInvalidHotkey?()
                return nil
            }

            hotkey = Hotkey(keyCode: UInt32(event.keyCode), modifiers: modifiers)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
