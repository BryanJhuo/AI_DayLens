import Foundation

class LLMService {
    private let apiKey = "API-KEY" // Replace with your actual API key
    private let endpoint = "https://openrouter.ai/api/v1/chat/completions"
    
    func analyzeEmotion(input: String, model: String) async throws -> EmotionAnalysisResult {
        if apiKey.isEmpty || apiKey.starts(with: "demo") {
            return EmotionAnalysisResult(
                emotion: "🧪 模擬分析",
                message: "雖然我無法即時分析，但我相信你已經做得很好了。"
            )
        }

        let prompt = """
        你是一個情感分析專家，也是擅長傾聽與給予溫暖鼓勵的 AI 好朋友。

        請根據使用者提供的心情內容，完成以下任務：
        1. 判斷使用者的情緒類型，只能選擇以下其中一種（快樂、悲傷、焦慮、放鬆、中性）。
        2. 根據判斷的情緒，回應一段（2~3句話）自然、真誠、富有同理心的安慰或鼓勵語句。
        3. 回應必須使用繁體中文。
        4. 回傳格式請保持 JSON 格式，例如：

        {
        "emotion": "快樂",
        "message": "今天的你光芒萬丈，持續閃耀著屬於你的光！"
        }

        使用者心情內容如下：
        「\(input)」
        """

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            // "max_tokens": 100,
            "temperature": 0.8
        ]
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("https://openrouter-ai", forHTTPHeaderField: "Referer")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("OpenRouter API error: \(errorResponse)")
            return EmotionAnalysisResult(
                emotion: "❌ 分析失敗",
                message: "API 錯誤：\(errorResponse)"
            )
        }

        if let decoded = try? JSONDecoder().decode(OpenRouterResponse.self, from: data),
            let content = decoded.choices.first?.message.content {
            
            if let startRange = content.firstIndex(of: "{"), 
                let endRange = content.lastIndex(of: "}") {
                
                if startRange <= endRange {
                    let jsonSubstring = content[startRange...endRange]
                    let jsonString = String(jsonSubstring)


                    if let jsonData = jsonString.data(using: .utf8) {
                        do {
                            let result: EmotionAnalysisResult = try JSONDecoder().decode(EmotionAnalysisResult.self, from: jsonData)
                            return result
                        }
                        catch {
                            print("JSON Decoding error: \(error)")
                            return EmotionAnalysisResult(
                                emotion: "❌ 分析失敗",
                                message: "解析 JSON 錯誤：\(error.localizedDescription)"
                            )
                        }
                    }
                    else {
                        return EmotionAnalysisResult(
                            emotion: "❌ 分析失敗",
                            message: "無法轉換 JSON 字串"
                        )
                    }
                }
                else {
                    return EmotionAnalysisResult(
                        emotion: "❌ 分析失敗",
                        message: "無法找到 JSON 字串"
                    )
                }
            } else {
                return EmotionAnalysisResult(
                    emotion: "❌ 分析失敗",
                    message: "無法找到 JSON 字串"
                )
            }
        }
        else {
            return EmotionAnalysisResult(
                emotion: "❌ 分析失敗",
                message: "無法解析 API 回應"
            )
        }
    }
}

// MARK: - OpenRouter Response Struct
struct OpenRouterResponse: Decodable {
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}