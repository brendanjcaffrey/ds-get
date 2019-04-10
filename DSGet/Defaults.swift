import Foundation

class Defaults {
    static let hostKey = "address"
    static let userKey = "user"
    static let passwordKey = "password"

    typealias Values = (host: String, user: String, password: String)

    static func save(_ values: Values) {
        save(hostKey, values.host)
        save(userKey, values.user)
        save(passwordKey, values.password)
    }

    static func load() -> Values {
        return (load(hostKey), load(userKey), load(passwordKey) )
    }

    private static func save(_ key: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    private static func load(_ key: String) -> String {
        if let value = UserDefaults.standard.object(forKey: key) as? String {
            return value
        } else {
            return ""
        }
    }
}
