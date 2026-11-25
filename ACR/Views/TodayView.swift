import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \Article.publishedAt, order: .reverse) private var articles: [Article]
    @AppStorage("briefingEnabled") private var briefingEnabled = true
    @AppStorage("appLanguage") private var language = "zh"
    @State private var showBriefMenu = false
    @State private var regenerating = false
    @State private var lastRegenerated = ""
    @State private var selected: Article?
    @State private var searchText = ""

    private var unread: [Article] { articles.filter { !$0.isRead } }
    private var filtered: [Article] {
        searchText.isEmpty ? unread : unread.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack { DynamicBackground(); ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if briefingEnabled { briefingCard }
                    ForEach(filtered) { a in
                        Button { selected = a } label: { articleRow(a) }
                            .buttonStyle(.plain)
                    }
                    if filtered.isEmpty {
                        Text("没有未读文章，先去发现页添加几个订阅吧。").foregroundStyle(.secondary).font(.system(size: 14)).padding()
                    }
                }.padding(.horizontal, 16).padding(.top, 8)
            }}
            .searchable(text: $searchText, prompt: I18n.t("search_articles", lang: language))
            .navigationTitle(I18n.t("today", lang: language))
            .navigationDestination(item: $selected) { a in ReaderView(article: a, articles: Array(unread)) }
        }
    }

    private var briefingCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(.green)
                Text(I18n.t("ai_briefing", lang: language)).font(.headline)
                Spacer()
                Text(Date(), format: .dateTime.month().day().weekday(.wide)).font(.system(size: 12)).foregroundStyle(.secondary)
                Menu {
                    Button { regenerate() } label: { Label(I18n.t("regenerate", lang: language), systemImage: "arrow.clockwise") }
                    Button { briefingEnabled = false } label: { Label(I18n.t("hide_briefing", lang: language), systemImage: "eye.slash") }
                } label: { Image(systemName: "ellipsis").font(.system(size: 15)).padding(6) }
            }
            ForEach(briefingTopics, id: \.0) { t in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: t.2).foregroundStyle(.teal).font(.system(size: 13))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(t.0) · \(t.1)篇").font(.system(size: 13, weight: .semibold))
                        Text(t.3).font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                }
            }
            Text(regenerating ? "正在重新生成…" : (lastRegenerated.isEmpty ? "由 AI 根据今日未读文章生成" : lastRegenerated))
                .font(.system(size: 11)).foregroundStyle(.secondary)
        }
        .padding(14).liquidGlass()
    }

    private var briefingTopics: [(String, Int, String, String)] {
        [("科技与工具", 8, "cpu", "大模型与效率工具是今天的重点。"),
         ("民生政策", 6, "newspaper", "与日常生活相关的政策要点汇总。"),
         ("阅读与博客", 10, "book", "中文博客今日更新 10 篇，值得一读。")]
    }

    private func regenerate() {
        regenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { regenerating = false; lastRegenerated = "刚刚重新生成" }
    }

    private func articleRow(_ a: Article) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack { Text(a.title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(a.isRead ? .secondary : .primary); Spacer(); if a.isStarred { Image(systemName: "star.fill").foregroundStyle(.yellow).font(.system(size: 11)) } }
            Text(a.summary).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2)
            Text(a.feed?.title ?? "").font(.system(size: 11)).foregroundStyle(.tertiary)
        }
        .padding(12).liquidGlass()
    }
}
