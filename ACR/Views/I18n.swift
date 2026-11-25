import Foundation
/// 极简中英对照（v1 覆盖主界面；文章正文仍以原文为准）
enum I18n {
    static let dict: [String: [String: String]] = [
        "today": ["zh": "今日", "en": "Today"],
        "library": ["zh": "订阅", "en": "Library"],
        "settings": ["zh": "设置", "en": "Settings"],
        "search_articles": ["zh": "搜索文章", "en": "Search articles"],
        "unread": ["zh": "未读", "en": "Unread"],
        "starred": ["zh": "收藏", "en": "Starred"],
        "read_later": ["zh": "稍后读", "en": "Read Later"],
        "feeds": ["zh": "订阅", "en": "Feeds"],
        "edit": ["zh": "编辑", "en": "Edit"],
        "ai_briefing": ["zh": "AI 简报", "en": "AI Briefing"],
        "regenerate": ["zh": "重新生成", "en": "Regenerate"],
        "hide_briefing": ["zh": "关闭今日简报", "en": "Hide today's briefing"],
        "swipe_next": ["zh": "上滑下一篇", "en": "Swipe up for next article"],
        "ai_summary": ["zh": "AI 总结", "en": "AI Summary"],
        "language": ["zh": "语言", "en": "Language"],
        "daily_push": ["zh": "每日推送", "en": "Daily Push"],
        "dynamic_bg": ["zh": "动态背景", "en": "Dynamic Background"],
        "icloud_sync": ["zh": "iCloud 同步", "en": "iCloud Sync"],
        "add_feed": ["zh": "添加订阅", "en": "Add Feed"],
        "discover": ["zh": "发现", "en": "Discover"],
        "ai_providers": ["zh": "AI 提供商", "en": "AI Providers"],
        "account": ["zh": "账号", "en": "Account"],
        "login_register": ["zh": "登录 / 注册", "en": "Sign In / Sign Up"],
        "local_mode": ["zh": "不登录也能用 · 本机模式", "en": "Use locally without signing in"],
    ]
    static func t(_ key: String, lang: String = UserDefaults.standard.string(forKey: "appLanguage") ?? "zh") -> String {
        dict[key]?[lang] ?? dict[key]?["zh"] ?? key
    }
}
