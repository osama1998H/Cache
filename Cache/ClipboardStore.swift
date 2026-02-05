import Foundation
import Combine

final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    private let maxItems = 20

    func add(text: String, sourceAppName: String?) {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return }

        if let first = items.first, normalize(first.text) == normalized {
            return
        }

        if let existingIndex = items.firstIndex(where: { normalize($0.text) == normalized }) {
            items.remove(at: existingIndex)
        }

        let item = ClipboardItem(text: text, sourceAppName: sourceAppName)
        items.insert(item, at: 0)

        if items.count > maxItems {
            items.removeLast(items.count - maxItems)
        }
    }

    func filteredItems(query: String) -> [ClipboardItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.text.localizedCaseInsensitiveContains(q) }
    }

    private func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
