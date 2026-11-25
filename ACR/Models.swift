import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade) var feeds: [Feed] = []
    init(name: String, sortOrder: Int = 0) { self.name = name; self.sortOrder = sortOrder }
}

@Model
final class Feed {
    var title: String
    var url: String          // feed URL
    var siteURL: String
    var iconName: String     // single-letter / emoji-free fallback identifier
    var folder: Folder?
    var etag: String?
    var lastModified: String?
    var lastFetched: Date?
    @Relationship(deleteRule: .cascade) var articles: [Article] = []
    init(title: String, url: String, siteURL: String, iconName: String = "", folder: Folder? = nil) {
        self.title = title; self.url = url; self.siteURL = siteURL; self.iconName = iconName; self.folder = folder
    }
    var unreadCount: Int { articles.filter { !$0.isRead }.count }
}

@Model
final class Article {
    var title: String
    var link: String
    var summary: String
    var content: String
    var author: String
    var publishedAt: Date
    var isRead: Bool = false
    var isStarred: Bool = false
    var isSavedForLater: Bool = false
    var aiSummary: String = ""
    var feed: Feed?
    init(title: String, link: String, summary: String = "", content: String = "", author: String = "", publishedAt: Date = Date(), feed: Feed? = nil) {
        self.title = title; self.link = link; self.summary = summary; self.content = content
        self.author = author; self.publishedAt = publishedAt; self.feed = feed
    }
}

@Model
final class AIProvider {
    var name: String
    var baseURL: String      // OpenAI-compatible base URL, e.g. https://api.openai.com/v1
    var model: String
    var apiKey: String       // stored locally only; never committed
    var isDefault: Bool = false
    var isLocal: Bool = false // Ollama / LM Studio
    init(name: String, baseURL: String, model: String, apiKey: String = "", isDefault: Bool = false, isLocal: Bool = false) {
        self.name = name; self.baseURL = baseURL; self.model = model; self.apiKey = apiKey; self.isDefault = isDefault; self.isLocal = isLocal
    }
}

// MARK: - App-wide settings (UserDefaults-backed, single source in Store.swift)
enum ReaderFont: String, CaseIterable { case system, serif, kai
    var displayName: String { switch self { case .system: return "system_font"; case .serif: return "serif_font"; case .kai: return "kai_font" } }
}
