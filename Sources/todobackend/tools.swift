//  Created by Denis Malykh on 15.11.2021.

import Foundation
import Swifter

#if os(Linux)
import FoundationNetworking
#endif

extension Dictionary where Key == String {
    subscript(caseInsensitive key: Key) -> Value? {
        get {
            if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
                return self[k]
            }
            return nil
        }
        set {
            if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
                self[k] = newValue
            } else {
                self[key] = newValue
            }
        }
    }
}

func r<T: Encodable>(_ obj: () throws -> T) -> HttpResponse {
    do {
        let data = try JSONEncoder().encode(obj())
        return .ok(.data(data, contentType: "application/json; charset=utf-8"))
    } catch UserErrors.duplicateItem {
        return .badRequest(.text("duplicate item"))
    } catch UserErrors.unsychronizedData {
        return .badRequest(.text("unsynchronized data"))
    } catch UserErrors.noSuchItem {
        return .notFound
    } catch {
        return .internalServerError
    }
}

func r<T: Encodable>(_ obj: T) -> HttpResponse {
    r {
        obj
    }
}

func auth(req: HttpRequest) -> String? {
    guard let auth = req.headers[caseInsensitive: "Authorization"] else {
        return nil
    }

    if auth.hasPrefix("Bearer") {
        let token = auth.suffix(from: auth.index(auth.startIndex, offsetBy: "Bearer ".count))
        guard let user = availableBearers["\(token)"] else {
            return nil
        }

        return user
    }

    if auth.hasPrefix("OAuth") {
        print("detected oauth auth")
        let token = auth.suffix(from: auth.index(auth.startIndex, offsetBy: "OAuth ".count))
        let session = URLSession.shared
        var request = URLRequest(
            url: URL(string: "https://login.yandex.ru/info?format=json")!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let sem = DispatchSemaphore(value: 0)
        var user: String? = nil
        DispatchQueue.global().async {
            let task = session.dataTask(with: request) { data, response, error in
                print("\tAuth \(error) \((response as? HTTPURLResponse)?.allHeaderFields)")
                if let data = data {
                    let dict = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = dict as? [String: Any], let id = dict["id"] as? String {
                        user = id
                    }
                }
                sem.signal()
            }
            task.resume()
        }
        sem.wait(timeout: .now() + 15.0)
        return user
    }

    return nil
}
