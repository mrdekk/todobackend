//  Created by Denis Malykh on 15.11.2021.

import Foundation
import todolib

struct TodoListRequest: Codable, Equatable {
    let list: [TodoItem]
}
