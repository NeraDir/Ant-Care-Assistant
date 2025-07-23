import Foundation

class OpenAIService: ObservableObject {
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func getAntAdvice(question: String) async -> String {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        guard let url = URL(string: baseURL) else {
            await MainActor.run {
                errorMessage = "Invalid URL"
            }
            return "Error: Invalid API URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemMessage = """
        You are an expert ant keeper and myrmecologist. Provide helpful, accurate advice about ant keeping, colony management, species care, feeding, housing, and general ant husbandry. Focus on practical, actionable advice. Keep responses concise but informative. If the question is not related to ant keeping, politely redirect the conversation back to ant care topics.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": question]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    await MainActor.run {
                        errorMessage = "API Error: Status code \(httpResponse.statusCode)"
                    }
                    return "Sorry, I'm having trouble connecting to the AI service right now. Please try again later."
                }
            }
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                await MainActor.run {
                    errorMessage = "Invalid response format"
                }
                return "Sorry, I received an unexpected response. Please try again."
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return "Sorry, I encountered an error while processing your request. Please check your internet connection and try again."
        }
    }
} 