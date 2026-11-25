import Foundation

/// OpenAI 兼容接口调用骨架。Key 只由用户在设置里填写、存本机，代码里没有任何 Key。
/// 不填 Key 时调用方应显示本地占位文案，不得编造 AI 结果。
struct AIService {
    struct ChatMessage: Encodable { let role: String; let content: String }
    struct ChatRequest: Encodable {
        let model: String
        let messages: [ChatMessage]
        let temperature: Double = 0.7
    }
    struct ChatResponse: Decodable {
        struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }
        let choices: [Choice]
    }

    static func summarize(provider: AIProvider, text: String) async throws -> String {
        guard !provider.apiKey.isEmpty else { throw NSError(domain: "ACR", code: 1, userInfo: [NSLocalizedDescriptionKey: "未配置 AI 提供商 Key"]) }
        var base = provider.baseURL.trimmingCharacters(in: .whitespaces)
        if base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: base + "/chat/completions") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(provider.apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(ChatRequest(model: provider.model, messages: [
            ChatMessage(role: "system", content: "用中文给出一句话摘要，再给 3 个要点。"),
            ChatMessage(role: "user", content: String(text.prefix(6000))),
        ]))
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(ChatResponse.self, from: data).choices.first?.message.content ?? ""
    }

    static func ask(provider: AIProvider, question: String, context: String) async throws -> String {
        guard !provider.apiKey.isEmpty else { throw NSError(domain: "ACR", code: 1, userInfo: [NSLocalizedDescriptionKey: "未配置 AI 提供商 Key"]) }
        var base = provider.baseURL.trimmingCharacters(in: .whitespaces)
        if base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: base + "/chat/completions") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(provider.apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(ChatRequest(model: provider.model, messages: [
            ChatMessage(role: "system", content: "你是 RSS 阅读助手，只根据提供的文章内容回答，并标注引用来源。"),
            ChatMessage(role: "user", content: "文章：\n" + String(context.prefix(6000)) + "\n\n问题：" + question),
        ]))
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(ChatResponse.self, from: data).choices.first?.message.content ?? ""
    }
}
