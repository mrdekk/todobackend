//  Created by Denis Malykh on 15.11.2021.

import Foundation
import todolib

struct TodoItemResponse: Codable, Equatable {
    let status: Status
    let element: TodoItem
    let revision: Int
}
