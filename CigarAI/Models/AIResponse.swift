import Foundation

struct AIResponse: Codable {
    let id: String
    let created: Int
    let model: String
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}
