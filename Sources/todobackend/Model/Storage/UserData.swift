//  Created by Denis Malykh on 21.11.2021.

import Foundation
import todolib

struct UserData: Codable, Equatable {
    let userId: String
    let todoList: [TodoItem]
    let revision: Int

    func addingItem(_ item: TodoItem) -> UserData {
        UserData(
            userId: userId,
            todoList: todoList + [item],
            revision: revision + 1
        )
    }

    func replacingItem(_ item: TodoItem, at index: Int) -> UserData {
        var tdl = todoList
        tdl[index] = item
        return UserData(
            userId: userId,
            todoList: tdl,
            revision: revision + 1
        )
    }

    func removingItem(at index: Int) -> UserData {
        var tdl = todoList
        tdl.remove(at: index)
        return UserData(
            userId: userId,
            todoList: tdl,
            revision: revision + 1
        )
    }
}
