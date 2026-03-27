import Foundation

struct Jar: Codable {
    let id: String
    let name: String
    let balance: Double
    let goal: Double
    let date: Date?
}
