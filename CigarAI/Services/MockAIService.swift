import Foundation

class MockAIService: AIService {
    override func getAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let mockResponse = AIResponse(
            id: "mock_id",
            created: Int(Date().timeIntervalSince1970),
            model: "gpt-4o-mini",
            choices: [Choice(message: Message(role: "assistant", content: "Try a Macanudo Cafe for a mild, creamy cigar perfect for beginners. Pair it with a light whiskey like Jameson."), finishReason: "stop")]
        )
        completion(.success(mockResponse.choices.first!.message.content))
    }
}

