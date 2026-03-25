import Foundation

struct Jar: Codable {
    let id: String
    let name: String
    let contents: [Double]
    let userID: String
    let date: Date
}
