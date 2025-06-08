import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case apiKeyMissing
}

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

class AIService {
    private var apiKey: String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["OpenAIAPIKey"] as? String else {
            return nil
        }
        return key
    }
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func getAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey else {
            completion(.failure(NetworkError.apiKeyMissing))
            return
        }
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a cigar expert assistant called Cigar Concierge. Provide concise, accurate, and helpful answers about cigars, including recommendations, pairings, and beginner tips. Focus on cigar brands, flavor profiles, and occasions."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 200
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
                if let firstChoice = aiResponse.choices.first {
                    completion(.success(firstChoice.message.content))
                } else {
                    completion(.failure(NetworkError.noData))
                }
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}
