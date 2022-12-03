//  Created by Denis Malykh on 04.06.2021.

import Foundation
import todolib

struct TodoListResponse: Codable, Equatable {
    let status: Status
    let list: [TodoItem]
    let revision: Int
}
