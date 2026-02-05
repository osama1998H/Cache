import XCTest
@testable import Cache

final class ClipboardStoreTests: XCTestCase {
    func testAddsAndCapsAtTwenty() {
        let store = ClipboardStore()
        for i in 0..<25 {
            store.add(text: "Item \(i)", sourceAppName: nil)
        }
        XCTAssertEqual(store.items.count, 20)
        XCTAssertEqual(store.items.first?.text, "Item 24")
        XCTAssertEqual(store.items.last?.text, "Item 5")
    }

    func testDedupesAndMovesToTop() {
        let store = ClipboardStore()
        store.add(text: "First", sourceAppName: nil)
        store.add(text: "Second", sourceAppName: nil)
        store.add(text: "First", sourceAppName: nil)

        XCTAssertEqual(store.items.count, 2)
        XCTAssertEqual(store.items.first?.text, "First")
    }

    func testSearchFiltersCaseInsensitive() {
        let store = ClipboardStore()
        store.add(text: "Hello World", sourceAppName: nil)
        store.add(text: "Another", sourceAppName: nil)

        let results = store.filteredItems(query: "world")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.text, "Hello World")
    }
}
