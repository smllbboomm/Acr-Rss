import SwiftUI
import SwiftData

struct AskAIView: View {
    @Query private var providers: [AIProvider]
    @State private var question = ""
    @State private var answer = ""
    @State private var isAsking = false
    private let suggestions = ["What should I read first?", "Summarize today's news", "Anything I can skip?"]

    var body: some View {
        ZStack { DynamicBackground(); VStack(spacing: 16) {
            HStack {
                Button {} label: { Image(systemName: "sidebar.left").font(.system(size: 15)) }.liquidGlassCircle().frame(width: 36, height: 36)
                Spacer(); Text("Ask AI").font(.headline); Spacer()
                Button {} label: { Image(systemName: "square.and.pencil").font(.system(size: 15)) }.liquidGlassCircle().frame(width: 36, height: 36)
            }
            Image(systemName: "sparkles").font(.system(size: 28)).foregroundStyle(.green).padding(12).liquidGlassCircle()
            Text("Ask about your articles").font(.system(size: 22, weight: .bold))
            Text("Answers come from your own feeds, with the articles they're based on. AI can also mark articles as read, star them or save them for later, after you confirm.")
                .font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.leading)
            ForEach(suggestions, id: \.self) { s in
                Button { question = s } label: { Text(s).font(.system(size: 13)).padding(.horizontal, 14).padding(.vertical, 8) }
                    .liquidGlass()
            }
            if !answer.isEmpty { Text(answer).font(.system(size: 14)).padding(12).liquidGlass() }
            Spacer()
            HStack {
                TextField("Ask anything about your…", text: $question)
                Menu("All Articles") { Button("All Articles") {}; Button("Unread only") {} }.font(.system(size: 12))
                Button { ask() } label: { Image(systemName: "arrow.up").foregroundStyle(.white).padding(8).background(Color.green, in: Circle()) }
                    .disabled(question.isEmpty || isAsking)
            }
            .padding(10).liquidGlass()
        }.padding(16) }
    }

    private func ask() {
        guard let p = providers.first(where: { $0.isDefault }) ?? providers.first else {
            answer = "未配置 AI 提供商：请先去设置 → AI 提供商添加一家并填入 Key。"; return
        }
        isAsking = true
        Task {
            do { answer = try await AIService.ask(provider: p, question: question, context: "今日未读文章摘要。") }
            catch { answer = "调用失败：\(error.localizedDescription)，请检查 Key 与网络。" }
            isAsking = false
        }
    }
}
