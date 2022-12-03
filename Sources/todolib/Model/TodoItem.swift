//  Created by Denis Malykh on 24.05.2021.

import Foundation

public struct TodoItem: Codable, Equatable {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadline: Date?
    public let color: String?
    public let isDone: Bool
    public let createdAt: Date
    public let changedAt: Date
    public let lastUpdatedBy: String

    public init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance = .basic,
        deadline: Date? = nil,
        isDone: Bool,
        color: String? = nil,
        createdAt: Date,
        changedAt: Date,
        lastUpdatedBy: String
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.color = color
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.lastUpdatedBy = lastUpdatedBy
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isDone = "done"
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        if let deadline = deadline {
            try container.encode(Int(deadline.timeIntervalSince1970), forKey: .deadline)
        }
        try container.encode(isDone, forKey: .isDone)
        if let color = color {
            try container.encode(color, forKey: .color)
        }
        try container.encode(Int(createdAt.timeIntervalSince1970), forKey: .createdAt)
        try container.encode(Int(changedAt.timeIntervalSince1970), forKey: .changedAt)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        importance = try container.decode(Importance.self, forKey: .importance)
        if let deadlineVal = try container.decodeIfPresent(Int.self, forKey: .deadline) {
            deadline = Date(timeIntervalSince1970: TimeInterval(deadlineVal))
        } else {
            deadline = nil
        }
        isDone = try container.decode(Bool.self, forKey: .isDone)
        if let colorVal = try container.decodeIfPresent(String.self, forKey: .color) {
            color = colorVal
        } else {
            color = nil
        }
        createdAt = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int.self, forKey: .createdAt)))
        changedAt = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int.self, forKey: .changedAt)))
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
    }

    public func with(id: String) -> TodoItem {
        TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            color: color,
            createdAt: createdAt,
            changedAt: changedAt,
            lastUpdatedBy: lastUpdatedBy
        )
    }
}
