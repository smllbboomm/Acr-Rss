import SwiftUI
import SwiftData

struct ReaderView: View {
    let article: Article
    let articles: [Article]
    @AppStorage("readerFontSize") private var fontSize = 15.0
    @AppStorage("readerFont") private var readerFont = "system"
    @AppStorage("isDarkMode") private var isDark = false
    @AppStorage("aiSummaryEnabled") private var aiSummaryEnabled = true
    @State private var current: Article
    @State private var showSettings = false
    @State private var showNextHint = false
    @Environment(\.dismiss) private var dismiss

    init(article: Article, articles: [Article]) { self.article = article; self.articles = articles; _current = State(initialValue: article) }

    private var index: Int { articles.firstIndex(where: { $0.id == current.id }) ?? 0 }
    private var next: Article? { index + 1 < articles.count ? articles[index + 1] : nil }

    var body: some View {
        ZStack { DynamicBackground(); ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(current.title).font(.system(size: 20, weight: .bold))
                Text("\(current.feed?.title ?? "") · \(current.publishedAt, format: .dateTime.month().day())").font(.system(size: 12)).foregroundStyle(.secondary)
                if aiSummaryEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("AI 总结", systemImage: "sparkles").font(.system(size: 12, weight: .semibold)).foregroundStyle(.green)
                        Text(current.aiSummary.isEmpty ? (current.summary.isEmpty ? "暂无 AI 总结，配置 AI 提供商后自动生成。" : current.summary) : current.aiSummary)
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }.padding(12).liquidGlass()
                }
                Text(current.content.isEmpty ? current.summary : current.content)
                    .font(fontForReader(size: fontSize))
                    .onAppear { current.isRead = true }
                // 读到底：上滑下一篇
                Button { goNext() } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.up").font(.system(size: 12))
                        Text("上滑下一篇").font(.system(size: 12)).foregroundStyle(.secondary)
                        if let n = next { Text(n.title).font(.system(size: 12)).foregroundStyle(.tertiary).lineLimit(1) }
                    }.frame(maxWidth: .infinity).padding(.vertical, 16)
                }
                .onAppear { showNextHint = true }
            }.padding(16)
        }}
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("阅读设定", systemImage: "textformat.size") { showSettings = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { current.isStarred.toggle() } label: { Image(systemName: current.isStarred ? "star.fill" : "star") }
            }
        }
        .sheet(isPresented: $showSettings) { readerSettingsSheet }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var readerSettingsSheet: some View {
        NavigationStack {
            Form {
                Section("字号") { Slider(value: $fontSize, in: 12...22, step: 1) { Text("字号 \(Int(fontSize))") } }
                Section("字体") {
                    Picker("字体", selection: $readerFont) {
                        Text("系统").tag("system"); Text("宋体").tag("serif"); Text("楷体").tag("kai")
                    }.pickerStyle(.segmented)
                }
                Section { Toggle("深色模式", isOn: $isDark); Toggle("AI 总结", isOn: $aiSummaryEnabled) }
                Section("翻译") { Text("使用系统翻译（离线可用），在文章内长按划词即可翻译。").font(.system(size: 13)).foregroundStyle(.secondary) }
            }.navigationTitle("阅读设定").toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { showSettings = false } } }
        }
        .presentationDetents([.medium])
    }

    private func fontForReader(size: Double) -> Font {
        switch readerFont {
        case "serif": return .custom("Songti SC", size: size)
        case "kai": return .custom("Kaiti SC", size: size)
        default: return .system(size: size)
        }
    }

    private func goNext() {
        if let n = next { current = n }
    }
}
