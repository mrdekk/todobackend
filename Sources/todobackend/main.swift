import Foundation
import Swifter

let server = HttpServer()

server.GET["/"] = { request in
    return .ok(.json(["ok": true]))
}

// MARK: - Bulk Actions

server.GET["/list"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
        let rnd = Int.random(in: 0...100)
        if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    return r { () -> TodoListResponse in
        let u = User(userId: user)
        u.load()
        return TodoListResponse(
            status: .ok,
            list: u.userData.todoList,
            revision: u.userData.revision
        )
    }
}

server.PATCH["/list"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
        let rnd = Int.random(in: 0...100)
        if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    guard let lastKnownRevisionStr = request.headers[caseInsensitive: "X-Last-Known-Revision"],
          let lastKnownRevision = Int(lastKnownRevisionStr) else {
        return .badRequest(.none)
    }

    print("last known revision \(lastKnownRevision)")

    let data = Data(request.body)
    let rq: TodoListRequest
    do {
        rq = try JSONDecoder().decode(TodoListRequest.self, from: data)
    } catch {
        return .badRequest(.none)
    }

    return r { () -> TodoListResponse in
        let u = User(userId: user)
        u.load()
        try u.mergeWithTodoList(rq.list, revision: lastKnownRevision)
        return TodoListResponse(
            status: .ok,
            list: u.userData.todoList,
            revision: u.userData.revision
        )
    }
}

server.POST["/list"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
        let rnd = Int.random(in: 0...100)
        if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    guard let lastKnownRevisionStr = request.headers[caseInsensitive: "X-Last-Known-Revision"],
          let lastKnownRevision = Int(lastKnownRevisionStr) else {
        return .badRequest(.none)
    }

    print("last known revision \(lastKnownRevision)")

    let data = Data(request.body)
    let rq: TodoItemRequest
    do {
        rq = try JSONDecoder().decode(TodoItemRequest.self, from: data)
    } catch {
        return .badRequest(.none)
    }

    return r { () -> TodoItemResponse in
        let u = User(userId: user)
        u.load()
        try u.addItem(rq.element, revision: lastKnownRevision)
        return TodoItemResponse(
            status: .ok,
            element: rq.element,
            revision: u.userData.revision
        )
    }
}

// MARK: - Individual Actions

server.GET["/list/:id"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
        let rnd = Int.random(in: 0...100)
        if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    guard let id = request.params[":id"] else {
        return .badRequest(.none)
    }

    return r { () -> TodoItemResponse in
        let u = User(userId: user)
        u.load()
        return TodoItemResponse(
            status: .ok,
            element: try u.item(with: id),
            revision: u.userData.revision
        )
    }
}

server.PUT["/list/:id"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
        let rnd = Int.random(in: 0...100)
        if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    guard let lastKnownRevisionStr = request.headers[caseInsensitive: "X-Last-Known-Revision"],
          let lastKnownRevision = Int(lastKnownRevisionStr) else {
        return .badRequest(.none)
    }

    print("last known revision \(lastKnownRevision)")

    guard let id = request.params[":id"] else {
        return .badRequest(.none)
    }

    let data = Data(request.body)
    let rq: TodoItemRequest
    do {
        rq = try JSONDecoder().decode(TodoItemRequest.self, from: data)
    } catch {
        return .badRequest(.none)
    }

    return r { () -> TodoItemResponse in
        let u = User(userId: user)
        u.load()
        try u.updateItem(rq.element.with(id: id), revision: lastKnownRevision)
        return TodoItemResponse(
            status: .ok,
            element: rq.element.with(id: id),
            revision: u.userData.revision
        )
    }
}

server.DELETE["/list/:id"] = { request in
    if let failsStr = request.headers[caseInsensitive: "X-Generate-Fails"], let fails = Int(failsStr) {
	let rnd = Int.random(in: 0...100)
	if rnd < fails {
            return .internalServerError
        }
    }

    guard let user = auth(req: request) else {
        return .unauthorized
    }

    print("user is \(user)")

    guard let lastKnownRevisionStr = request.headers[caseInsensitive: "X-Last-Known-Revision"],
          let lastKnownRevision = Int(lastKnownRevisionStr) else {
        return .badRequest(.none)
    }

    print("last known revision \(lastKnownRevision)")
    
    guard let id = request.params[":id"] else {
        return .badRequest(.none)
    }

    return r { () -> TodoItemResponse in
        let u = User(userId: user)
        u.load()
        let removedItem = try u.deleteItem(with: id, revision: lastKnownRevision)
        return TodoItemResponse(
            status: .ok,
            element: removedItem,
            revision: u.userData.revision
        )
    }
}

server.notFoundHandler = { _ in
    return .movedPermanently("https://github.com/404")
}

try? server.start(8002, forceIPv4: false, priority: .default)

//#if os(macOS)
while (true) {
    // iterate
}
//#elseif os(Linux)
//RunLoop().run(mode: .default, before: .distantFuture)
//#endif
