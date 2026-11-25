import Foundation
import SwiftData

/// 抓取 + 探测。条件请求用已存的 ETag / Last-Modified，304 不重复下载。
@MainActor
final class FeedService: ObservableObject {
    @Published var isRefreshing = false
    @Published var lastError: String?

    func refresh(feed: Feed, context: ModelContext) async {
        guard let url = URL(string: feed.url) else { return }
        var req = URLRequest(url: url)
        if let etag = feed.etag { req.setValue(etag, forHTTPHeaderField: "If-None-Match") }
        if let lm = feed.lastModified { req.setValue(lm, forHTTPHeaderField: "If-Modified-Since") }
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 304 { feed.lastFetched = Date(); return }
            if let http = resp as? HTTPURLResponse {
                feed.etag = http.value(forHTTPHeaderField: "ETag")
                feed.lastModified = http.value(forHTTPHeaderField: "Last-Modified")
            }
            let parsed = RSSParser().parse(data: data)
            if feed.title.isEmpty || feed.title == feed.url { feed.title = parsed.title }
            for p in parsed.articles where !feed.articles.contains(where: { $0.link == p.link }) {
                feed.articles.append(Article(title: p.title, link: p.link, summary: p.summary, content: p.content, author: p.author, publishedAt: p.publishedAt, feed: feed))
            }
            feed.lastFetched = Date()
            try? context.save()
        } catch { lastError = error.localizedDescription }
    }

    func refreshAll(feeds: [Feed], context: ModelContext) async {
        isRefreshing = true
        for f in feeds { await refresh(feed: f, context: context) }
        isRefreshing = false
    }

    /// 粘贴网页地址自动探测 feed：先试常见路径，再解析 HTML 找 <link rel="alternate" type="application/rss+xml">
    static func discoverFeedURL(from input: String) async -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let base = URL(string: trimmed.hasPrefix("http") ? trimmed : "https://" + trimmed) else { return nil }
        if base.pathExtension == "xml" || trimmed.contains("feed") || trimmed.contains("rss") || trimmed.contains("atom") { return base }
        for path in ["/feed", "/feed.xml", "/rss", "/rss.xml", "/atom.xml"] {
            if let u = URL(string: path, relativeTo: base) { if await headOK(u) { return u } }
        }
        // 解析 HTML 的 alternate 链接
        if let (data, _) = try? await URLSession.shared.data(from: base),
           let html = String(data: data, encoding: .utf8) {
            let pattern = #"rel=["']alternate["'][^>]*href=["']([^"']+)["']"#
            if let m = try? NSRegularExpression(pattern: pattern).firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let r = Range(m.range(at: 1), in: html) {
                return URL(string: String(html[r]), relativeTo: base)?.absoluteURL
            }
        }
        return nil
    }

    private static func headOK(_ url: URL) async -> Bool {
        var req = URLRequest(url: url); req.httpMethod = "HEAD"
        guard let (_, resp) = try? await URLSession.shared.data(for: req),
              let http = resp as? HTTPURLResponse else { return false }
        return (200...299).contains(http.statusCode)
    }
}
