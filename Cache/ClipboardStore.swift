import Foundation
import Combine

final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    let maxRecentItems = 20

    var pinnedCount: Int {
        items.filter(\.isPinned).count
    }

    var recentCount: Int {
        items.filter { !$0.isPinned }.count
    }

    func add(text: String, sourceAppName: String?) {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return }

        var sections = splitSections()

        if let existingPinnedIndex = sections.pinned.firstIndex(where: { normalize($0.text) == normalized }) {
            let existing = sections.pinned.remove(at: existingPinnedIndex)
            let refreshed = ClipboardItem(
                id: existing.id,
                text: text,
                sourceAppName: sourceAppName,
                isPinned: true
            )
            sections.pinned.insert(refreshed, at: 0)
            items = sections.pinned + sections.recent
            return
        }

        if let existingRecentIndex = sections.recent.firstIndex(where: { normalize($0.text) == normalized }) {
            sections.recent.remove(at: existingRecentIndex)
        }

        let item = ClipboardItem(text: text, sourceAppName: sourceAppName, isPinned: false)
        sections.recent.insert(item, at: 0)
        sections.recent = trimmedRecent(sections.recent)
        items = sections.pinned + sections.recent
    }

    func togglePinned(itemID: ClipboardItem.ID) {
        var sections = splitSections()

        if let pinnedIndex = sections.pinned.firstIndex(where: { $0.id == itemID }) {
            let item = sections.pinned.remove(at: pinnedIndex)
            let unpinned = ClipboardItem(
                id: item.id,
                text: item.text,
                timestamp: item.timestamp,
                sourceAppName: item.sourceAppName,
                isPinned: false
            )
            sections.recent.insert(unpinned, at: 0)
            sections.recent = trimmedRecent(sections.recent)
            items = sections.pinned + sections.recent
            return
        }

        guard let recentIndex = sections.recent.firstIndex(where: { $0.id == itemID }) else { return }
        let item = sections.recent.remove(at: recentIndex)
        let pinned = ClipboardItem(
            id: item.id,
            text: item.text,
            timestamp: item.timestamp,
            sourceAppName: item.sourceAppName,
            isPinned: true
        )
        sections.pinned.insert(pinned, at: 0)
        items = sections.pinned + sections.recent
    }

    func filteredSections(query: String) -> (pinned: [ClipboardItem], recent: [ClipboardItem]) {
        let sections = splitSections()
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            return (sections.pinned, sections.recent)
        }

        let pinned = sections.pinned.filter { $0.text.localizedCaseInsensitiveContains(q) }
        let recent = sections.recent.filter { $0.text.localizedCaseInsensitiveContains(q) }
        return (pinned, recent)
    }

    func filteredItems(query: String) -> [ClipboardItem] {
        let sections = filteredSections(query: query)
        return sections.pinned + sections.recent
    }

    private func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private func splitSections() -> (pinned: [ClipboardItem], recent: [ClipboardItem]) {
        let pinned = items.filter(\.isPinned)
        let recent = items.filter { !$0.isPinned }
        return (pinned, recent)
    }

    private func trimmedRecent(_ recent: [ClipboardItem]) -> [ClipboardItem] {
        if recent.count > maxRecentItems {
            return Array(recent.prefix(maxRecentItems))
        }
        return recent
    }
}
