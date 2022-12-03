//  Created by Denis Malykh on 15.11.2021.

import Foundation
import todolib

func makeDummyList() -> [TodoItem] {
    [
        TodoItem(
            id: UUID().uuidString,
            text: "Первая заметка",
            importance: .important,
            deadline: Date(timeIntervalSinceNow: 150),
            isDone: false,
            createdAt: Date(),
            changedAt: Date(),
            lastUpdatedBy: "mrdekk"
        ),
        TodoItem(
            id: UUID().uuidString,
            text: "Вторая заметка",
            importance: .low,
            deadline: nil,
            isDone: true,
            createdAt: Date(),
            changedAt: Date(),
            lastUpdatedBy: "mrdekk"
        ),
        TodoItem(
            id: UUID().uuidString,
            text: "Последняя заметка",
            importance: .basic,
            deadline: nil,
            isDone: false,
            createdAt: Date.distantPast,
            changedAt: Date(),
            lastUpdatedBy: "nekto"
        )
    ]
}
