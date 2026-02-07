import XCTest
@testable import Cache

final class ClipboardStoreTests: XCTestCase {
    func testAddsAndCapsAtTwenty() {
        let store = ClipboardStore()
        for i in 0..<25 {
            store.add(text: "Item \(i)", sourceAppName: nil)
        }

        XCTAssertEqual(store.recentCount, 20)
        XCTAssertEqual(store.pinnedCount, 0)
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

    func testPinsDoNotCountTowardRecentCap() throws {
        let store = ClipboardStore()
        for i in 0..<20 {
            store.add(text: "Item \(i)", sourceAppName: nil)
        }

        let toPin = try XCTUnwrap(store.items.first(where: { $0.text == "Item 10" }))
        store.togglePinned(itemID: toPin.id)

        store.add(text: "Item 20", sourceAppName: nil)
        store.add(text: "Item 21", sourceAppName: nil)

        XCTAssertEqual(store.recentCount, 20)
        XCTAssertEqual(store.pinnedCount, 1)
        XCTAssertEqual(store.items.count, 21)
        XCTAssertEqual(store.items.filter { $0.text == "Item 10" }.count, 1)
        XCTAssertEqual(store.items.first(where: { $0.text == "Item 10" })?.isPinned, true)
    }

    func testPinnedDuplicateReusesSinglePinnedItem() throws {
        let store = ClipboardStore()
        store.add(text: "Alpha", sourceAppName: nil)
        store.add(text: "Beta", sourceAppName: nil)

        let alpha = try XCTUnwrap(store.items.first(where: { $0.text == "Alpha" }))
        store.togglePinned(itemID: alpha.id)
        store.add(text: "Alpha", sourceAppName: nil)

        XCTAssertEqual(store.items.filter { $0.text == "Alpha" }.count, 1)
        XCTAssertEqual(store.items.first?.text, "Alpha")
        XCTAssertEqual(store.items.first?.isPinned, true)
    }

    func testUnpinMovesItemToTopOfRecentAndEvictsOldestWhenNeeded() throws {
        let store = ClipboardStore()
        for i in 0..<20 {
            store.add(text: "Item \(i)", sourceAppName: nil)
        }
        store.add(text: "Pinned One", sourceAppName: nil)

        let pinned = try XCTUnwrap(store.items.first(where: { $0.text == "Pinned One" }))
        store.togglePinned(itemID: pinned.id)
        store.add(text: "Filler", sourceAppName: nil)

        XCTAssertEqual(store.pinnedCount, 1)
        XCTAssertEqual(store.recentCount, 20)

        store.togglePinned(itemID: pinned.id)

        XCTAssertEqual(store.pinnedCount, 0)
        XCTAssertEqual(store.recentCount, 20)
        XCTAssertEqual(store.items.first?.text, "Pinned One")
        XCTAssertFalse(store.items.contains(where: { $0.text == "Item 1" }))
    }

    func testFilteredSectionsPreservePinnedThenRecentOrdering() throws {
        let store = ClipboardStore()
        store.add(text: "Apple Pin", sourceAppName: nil)
        store.add(text: "Banana Recent", sourceAppName: nil)
        store.add(text: "Apricot Recent", sourceAppName: nil)
        store.add(text: "Alpha Pin", sourceAppName: nil)

        let apple = try XCTUnwrap(store.items.first(where: { $0.text == "Apple Pin" }))
        let alpha = try XCTUnwrap(store.items.first(where: { $0.text == "Alpha Pin" }))
        store.togglePinned(itemID: apple.id)
        store.togglePinned(itemID: alpha.id)

        let sections = store.filteredSections(query: "a")
        XCTAssertEqual(sections.pinned.map(\.text), ["Alpha Pin", "Apple Pin"])
        XCTAssertEqual(sections.recent.map(\.text), ["Apricot Recent", "Banana Recent"])

        let flattened = store.filteredItems(query: "a")
        XCTAssertEqual(flattened.map(\.text), ["Alpha Pin", "Apple Pin", "Apricot Recent", "Banana Recent"])
    }
}
