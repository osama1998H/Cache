import Foundation

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    let sourceAppName: String?

    init(id: UUID = UUID(), text: String, timestamp: Date = Date(), sourceAppName: String? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.sourceAppName = sourceAppName
    }
}
