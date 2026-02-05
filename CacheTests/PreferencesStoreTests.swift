import XCTest
@testable import Cache

final class PreferencesStoreTests: XCTestCase {
    func testHotkeySaveAndLoad() {
        let suiteName = "CacheTestsPreferences"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = PreferencesStore(userDefaults: defaults)
        let custom = Hotkey(keyCode: 7, modifiers: 256) // 'X' with cmdKey
        store.hotkey = custom

        let reloaded = PreferencesStore(userDefaults: defaults)
        XCTAssertEqual(reloaded.hotkey, custom)
    }
}
