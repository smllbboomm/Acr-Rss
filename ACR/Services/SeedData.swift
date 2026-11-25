import Foundation

/// 12 个国内常用源。带“待核实”标注的地址未经实测，打不开时请在发现页用粘贴网址自动探测替换。
/// 已知常用公开地址：阮一峰 atom、少数派 feed、小众软件 feed、爱范儿 feed、机器之心 rss、IT之家 rss。
struct SeedFeed: Identifiable {
    let id = UUID()
    let title: String
    let feedURL: String
    let siteURL: String
    let folder: String
    let verified: Bool
}

enum SeedData {
    static let discoverFeeds: [SeedFeed] = [
        SeedFeed(title: "阮一峰的网络日志", feedURL: "https://www.ruanyifeng.com/blog/atom.xml", siteURL: "https://www.ruanyifeng.com/blog/", folder: "科技博客", verified: true),
        SeedFeed(title: "少数派", feedURL: "https://sspai.com/feed", siteURL: "https://sspai.com/", folder: "科技博客", verified: true),
        SeedFeed(title: "小众软件", feedURL: "https://www.appinn.com/feed/", siteURL: "https://www.appinn.com/", folder: "科技博客", verified: true),
        SeedFeed(title: "爱范儿", feedURL: "https://www.ifanr.com/feed", siteURL: "https://www.ifanr.com/", folder: "科技博客", verified: true),
        SeedFeed(title: "机器之心", feedURL: "https://www.jiqizhixin.com/rss", siteURL: "https://www.jiqizhixin.com/", folder: "科技博客", verified: true),
        SeedFeed(title: "IT之家", feedURL: "https://www.ithome.com/rss/", siteURL: "https://www.ithome.com/", folder: "科技博客", verified: true),
        // 以下 6 个为常见写法，待核实：若失效请用粘贴网址自动探测
        SeedFeed(title: "澎湃新闻", feedURL: "https://www.thepaper.cn/rss", siteURL: "https://www.thepaper.cn/", folder: "新闻资讯", verified: false),
        SeedFeed(title: "财新网", feedURL: "https://www.caixin.com/rss/", siteURL: "https://www.caixin.com/", folder: "新闻资讯", verified: false),
        SeedFeed(title: "界面新闻", feedURL: "https://www.jiemian.com/rss/", siteURL: "https://www.jiemian.com/", folder: "新闻资讯", verified: false),
        SeedFeed(title: "36氪", feedURL: "https://36kr.com/feed", siteURL: "https://36kr.com/", folder: "新闻资讯", verified: false),
        SeedFeed(title: "虎嗅网", feedURL: "https://www.huxiu.com/rss/0.xml", siteURL: "https://www.huxiu.com/", folder: "新闻资讯", verified: false),
        SeedFeed(title: "南方周末", feedURL: "https://www.infzm.com/rss", siteURL: "https://www.infzm.com/", folder: "新闻资讯", verified: false),
    ]

    static let sampleArticles: [(title: String, source: String, summary: String)] = [
        ("AI 工具正在重塑日常阅读方式", "少数派", "新一代阅读器把摘要、翻译和问答做进同一页，阅读成本明显下降。"),
        ("本周科技大事：大模型、芯片与开源", "阮一峰的网络日志", "一周值得关注的科技新闻汇总，涵盖模型发布与开源项目。"),
        ("澎湃新闻：民生政策要点解读", "澎湃新闻", "近期民生政策的核心变化与对普通人的影响。"),
        ("小众软件：三款值得装的效率工具", "小众软件", "本周推荐的三款免费效率工具，覆盖笔记、同步与阅读。"),
    ]
}
