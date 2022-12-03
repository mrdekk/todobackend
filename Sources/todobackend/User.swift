//  Created by Denis Malykh on 21.11.2021.

import Foundation
import todolib

enum UserErrors: Error {
    case duplicateItem
    case unsychronizedData
    case noSuchItem
}

class User {
    let userId: String

    private(set) var userData: UserData

    init(userId: String) {
        self.userId = userId
        self.userData = UserData(
            userId: userId,
            todoList: [],
            revision: 0
        )
    }

    func load() {
        do {
            let data = try Data(contentsOf: dataURL)
            userData = try JSONDecoder().decode(UserData.self, from: data)
        } catch {
            // do nothing
        }
    }

    func save() throws {
        let data = try JSONEncoder().encode(userData)
        try data.write(to: dataURL)
    }

    func addItem(_ item: TodoItem, revision: Int) throws {
        guard userData.revision == revision else {
            throw UserErrors.unsychronizedData
        }
        
        if userData.todoList.contains(where: { $0.id == item.id }) {
            throw UserErrors.duplicateItem
        }

        userData = userData.addingItem(item)
        try save()
    }

    func item(with id: String) throws -> TodoItem {
        guard let item = userData.todoList.first(where: { $0.id == id }) else {
            throw UserErrors.noSuchItem
        }

        return item
    }

    func updateItem(_ item: TodoItem, revision: Int) throws {
        guard userData.revision == revision else {
            throw UserErrors.unsychronizedData
        }
        
        guard let index = userData.todoList.firstIndex(where: { $0.id == item.id }) else {
            throw UserErrors.noSuchItem
        }

        userData = userData.replacingItem(item, at: index)
        try save()
    }

    func deleteItem(with id: String, revision: Int) throws -> TodoItem {
        guard userData.revision == revision else {
            throw UserErrors.unsychronizedData
        }

        guard let index = userData.todoList.firstIndex(where: { $0.id == id }) else {
            throw UserErrors.noSuchItem
        }

        let item = userData.todoList[index]
        userData = userData.removingItem(at: index)
        try save()

        return item
    }

    func mergeWithTodoList(_ todoList: [TodoItem], revision: Int) throws {
        let cset = Set(userData.todoList.map { $0.id })
        let rset = Set(todoList.map { $0.id })

        let toRemove = cset.subtracting(rset)
        let toAdd = rset.subtracting(cset)
        let toUpdate = cset.intersection(rset)

        var tdl = userData.todoList
        for id in toRemove {
            tdl.removeAll(where: { $0.id == id })
        }

        for id in toAdd {
            guard let item = todoList.first(where: { $0.id == id }) else {
                continue
            }
            tdl.append(item)
        }

        for id in toUpdate {
            guard let myIndex = tdl.firstIndex(where: { $0.id == id }),
                  let theirs = todoList.first(where: { $0.id == id }) else {
                continue
            }

            if theirs.changedAt > tdl[myIndex].changedAt {
                tdl[myIndex] = theirs
            }
        }

        userData = UserData(
            userId: userId,
            todoList: tdl,
            revision: max(userData.revision, revision) + 1
        )
        try save()
    }

    private var dataURL: URL {
        URL(fileURLWithPath: "u\(userId).json")
    }
}
