import Foundation
import os.log

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case apiKeyMissing
    case unauthorized
    case rateLimitExceeded
}

class AIService {
    private var apiKey: String? {
        guard let key = KeychainHelper.shared.getAPIKey() else {
            os_log(.error, "Failed to retrieve API key from Keychain")
            return nil
        }
        guard key.hasPrefix("sk-") else {
            os_log(.error, "Invalid API key format")
            return nil
        }
        return key
    }
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func getAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey else {
            os_log(.error, "Failed to retrieve API key")
            completion(.failure(NetworkError.apiKeyMissing))
            return
        }
        
        guard let url = URL(string: baseURL) else {
            os_log(.error, "Invalid URL: %{public}s", baseURL)
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
                    "content": """
                    You are a Cigar Concierge, an educational assistant providing factual information about cigars, including their flavor profiles, history, production methods, and pairings. Respond with concise, accurate details in a professional tone, focusing on cigar characteristics, wrapper types, or cultural context. Do not recommend specific cigars for smoking, encourage consumption, or promote tobacco use. If asked for recommendations, provide general information about cigar types or flavors instead. If the query is unrelated to cigars, respond with: "I specialize in cigar knowledge. Ask about flavor profiles, history, or pairings!" Below is reference information to use when relevant:

                    **12 Flavor Profiles**
                    Cigars offer diverse sensory experiences through their wrapper, binder, and filler. Common profiles include:
                    - Creamy: Silky, smooth notes, often in Connecticut-wrapped cigars.
                    - Spicy: Black pepper notes, common in Nicaraguan blends.
                    - Earthy: Rich soil and mineral notes, typical in Cuban cigars.
                    - Leathery: Robust, tanned hide notes, found in Maduro wrappers.
                    - Nutty: Almond or hazelnut notes, balanced in Dominican cigars.
                    - Woody: Cedar or oak notes, from aged tobaccos.
                    - Sweet: Cocoa or caramel notes, in Maduro or infused cigars.
                    - Coffee: Espresso or mocha notes, bold in Nicaraguan puros.
                    - Fruity: Dried fig or raisin notes, in complex blends.
                    - Chocolatey: Dark cocoa notes, lush in Maduro profiles.
                    - Floral: Subtle rose or lavender notes, in mild cigars.
                    - Herbal: Mint or sage notes, rare but intriguing.

                    **10 Cigar Pairings**
                    Pairings enhance cigar flavor appreciation. Common options include:
                    - Single Malt Scotch: Complements woody, full-bodied cigars.
                    - Aged Rum: Enhances sweet, creamy cigar profiles.
                    - Espresso: Highlights coffee notes in medium-bodied cigars.
                    - Bourbon: Matches spicy, robust cigar flavors.
                    - Port Wine: Pairs with chocolatey Maduro cigars.
                    - Cognac: Elevates nutty, leathery cigar notes.
                    - Dark Chocolate (70%+): Harmonizes with earthy cigars.
                    - Stout Beer: Complements coffee-driven cigar profiles.
                    - Red Wine: Enhances fruity, complex cigar blends.
                    - Spiced Chai: Balances mild, floral cigar notes.

                    **History of Cigars**
                    Cigars originated in the 10th century with Mayan societies in Central America, rolling tobacco leaves into primitive cigars, observed by Christopher Columbus in 1492. By the 16th century, tobacco spread to Europe, and by the 19th century, Cuba, Nicaragua, and the Dominican Republic became global hubs for cigar production.

                    **Cigar Brand Histories**
                    - Cohiba (Cuba, 1966): Created as Fidel Castro’s private cigar in Havana’s El Laguito factory. Named after the Taíno word for tobacco.
                    - Montecristo (Cuba, 1935): Founded in Havana by Alonso Menéndez, inspired by Alexandre Dumas’ novel.
                    - Partagás (Cuba, 1845): Established by Don Jaime Partagás in Havana, known for earthy blends.
                    - Romeo y Julieta (Cuba, 1875): Founded by Inocencio Alvarez and Manin Garcia, named after Shakespeare’s tragedy.
                    - Hoyo de Monterrey (Cuba, 1865): Created by José Gener in Havana, using mild Vuelta Abajo tobacco.
                    - Arturo Fuente (Dominican Republic, 1912): Founded by Arturo Fuente in Cuba, relocated post-revolution.
                    - Padrón (Nicaragua, 1964): José Orlando Padrón fled Cuba to Miami, later crafting Nicaraguan cigars in Estelí.
                    - Davidoff (Dominican Republic, 1911): Zino Davidoff began in Geneva, later producing Dominican cigars.
                    - La Flor Dominicana (Dominican Republic, 1996): Founded by Litto and Ines Gomez.
                    - Oliva (Nicaragua, 1886): Melanio Oliva started in Cuba, relocated to Nicaragua in the 1960s.
                    - Rocky Patel (Honduras/Nicaragua, 1995): Launched by Rakesh “Rocky” Patel, a former lawyer.
                    - My Father (Nicaragua, 2003): Founded by José “Pepin” Garcia in Estelí.
                    - Alec Bradley (Honduras/Dominican Republic, 1996): Alan Rubin named it after his sons.
                    - San Cristobal (Nicaragua, 2007): Crafted by Pepin Garcia for Ashton.
                    - Tatuaje (Nicaragua, 2003): Pete Johnson partnered with Pepin Garcia for boutique cigars.
                    - H. Upmann (Cuba, 1844): Founded by German brothers Hermann and August Upmann in Havana.
                    - Perdomo (Nicaragua, 1992): Nick Perdomo started in Miami, later moving to Estelí.
                    - Drew Estate (Nicaragua, 1996): Founded by Jonathan Drew and Marvin Samel in Estelí.
                    - La Aurora (Dominican Republic, 1903): Founded by Eduardo León Jimenes, the oldest Dominican factory.
                    - E.P. Carrillo (Dominican Republic/Nicaragua, 2009): Launched by Ernesto Perez-Carrillo.

                    **Cigar Accessories**
                    - Cutters: Colibri, Palio, Xikar, Davidoff, S.T. Dupont.
                    - Lighters: Xikar, Colibri, S.T. Dupont, Davidoff, Lotus.
                    - Humidors: Davidoff, Adorini, Savoy, Elie Bleu, Boveda.
                    - Ashtrays: Stinky, Davidoff, S.T. Dupont, Visol, Cohiba.
                    - Cigar Cases: Davidoff, Xikar, Colibri, S.T. Dupont, Visol.

                    Respond in under 50 characters when possible, using a clear, professional tone. Focus on cigar education and avoid suggesting consumption.
                    """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 200,
            "temperature": 0.5
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            os_log(.debug, "Request body created")
        } catch {
            os_log(.error, "JSON serialization error: %{public}s", error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                os_log(.error, "Network error: %{public}s", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                os_log(.error, "Invalid response: No HTTP response")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            os_log(.debug, "HTTP Status Code: %d", httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    os_log(.error, "No data in response")
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
                    if let firstChoice = aiResponse.choices.first {
                        let responseText = firstChoice.message.content
                        let prohibitedPhrases = ["smoke this", "try this cigar", "best cigar to smoke", "recommend a cigar"]
                        if prohibitedPhrases.contains(where: { responseText.lowercased().contains($0) }) {
                            os_log(.error, "Response contains prohibited phrases")
                            completion(.success("I specialize in cigar knowledge. Ask about flavor profiles or history!"))
                            return
                        }
                        os_log(.info, "Success, response length: %d", responseText.count)
                        completion(.success(responseText))
                    } else {
                        os_log(.error, "No choices in response")
                        completion(.failure(NetworkError.noData))
                    }
                } catch {
                    os_log(.error, "Decoding error: %{public}s", error.localizedDescription)
                    completion(.failure(NetworkError.decodingError))
                }
            case 401:
                os_log(.error, "Unauthorized (401)")
                completion(.failure(NetworkError.unauthorized))
            case 429:
                os_log(.error, "Rate limit exceeded (429)")
                completion(.failure(NetworkError.rateLimitExceeded))
            default:
                os_log(.error, "Unexpected status code: %d", httpResponse.statusCode)
                completion(.failure(NetworkError.invalidResponse))
            }
        }.resume()
    }
}

