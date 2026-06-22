import Foundation

public struct Reading: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let vitalType: VitalType
    public let value: Double
    public let unit: String
    public let source: ReadingSource
    public let date: Date
    public let notes: String?
    public let tags: [String]

    public init(
        id: UUID = UUID(),
        vitalType: VitalType,
        value: Double,
        unit: String,
        source: ReadingSource,
        date: Date,
        notes: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.vitalType = vitalType
        self.value = value
        self.unit = unit
        self.source = source
        self.date = date
        self.notes = notes
        self.tags = tags
    }
}

public enum ReadingSource: String, Codable, Sendable {
    case manual
    case healthKit
    case bluetooth
    case imported
}