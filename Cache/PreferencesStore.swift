import Foundation

final class PreferencesStore: ObservableObject {
    @Published var hotkey: Hotkey {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let hotkeyKeyCodeKey = "hotkey.keyCode"
    private let hotkeyModifiersKey = "hotkey.modifiers"

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        if defaults.object(forKey: hotkeyKeyCodeKey) != nil,
           defaults.object(forKey: hotkeyModifiersKey) != nil {
            let keyCode = UInt32(defaults.integer(forKey: hotkeyKeyCodeKey))
            let modifiers = UInt32(defaults.integer(forKey: hotkeyModifiersKey))
            self.hotkey = Hotkey(keyCode: keyCode, modifiers: modifiers)
        } else {
            self.hotkey = .default
        }
    }

    private func save() {
        defaults.set(Int(hotkey.keyCode), forKey: hotkeyKeyCodeKey)
        defaults.set(Int(hotkey.modifiers), forKey: hotkeyModifiersKey)
    }
}
