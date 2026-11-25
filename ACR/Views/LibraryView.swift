import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Query(sort: \Feed.title) private var feeds: [Feed]
    @Query(sort: \Article.publishedAt, order: .reverse) private var articles: [Article]
    @Environment(\.modelContext) private var context
    @AppStorage("appLanguage") private var language = "zh"
    @State private var searchText = ""
    @State private var collapsedFolders = Set<String>()
    @State private var showNewFolder = false
    @State private var newFolderName = ""

    private var unreadCount: Int { articles.filter { !$0.isRead }.count }
    private var starredCount: Int { articles.filter { $0.isStarred }.count }
    private var laterCount: Int { articles.filter { $0.isSavedForLater }.count }

    var body: some View {
        NavigationStack {
            ZStack { DynamicBackground(); ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        StatCard(icon: "circle", count: unreadCount, label: I18n.t("unread", lang: language))
                        StatCard(icon: "star", count: starredCount, label: I18n.t("starred", lang: language))
                        StatCard(icon: "bookmark", count: laterCount, label: I18n.t("read_later", lang: language))
                    }
                    topicsCard
                    HStack {
                        Text("\(I18n.t("feeds", lang: language)) · \(feeds.count)").font(.headline)
                        Spacer()
                        Button(I18n.t("edit", lang: language)) {}.foregroundStyle(.green).font(.system(size: 13))
                        Button { showNewFolder = true } label: { Label("新建分组", systemImage: "plus") }.font(.system(size: 13)).foregroundStyle(.green)
                    }
                    ForEach(folders) { folder in folderSection(folder) }
                    ForEach(feeds.filter { $0.folder == nil }) { feed in feedRow(feed) }
                }.padding(.horizontal, 16).padding(.top, 8)
            }}
            .searchable(text: $searchText, prompt: I18n.t("search_articles", lang: language))
            .navigationTitle(I18n.t("library", lang: language))
            .alert("新建分组", isPresented: $showNewFolder) {
                TextField("分组名", text: $newFolderName)
                Button("取消", role: .cancel) {}
                Button("创建") {
                    guard !newFolderName.isEmpty else { return }
                    context.insert(Folder(name: newFolderName, sortOrder: folders.count))
                    try? context.save(); newFolderName = ""
                }
            }
        }
    }

    private var topicsCard: some View {
        HStack {
            Image(systemName: "sparkles").foregroundStyle(.teal)
            VStack(alignment: .leading) { Text("Topics").font(.system(size: 14, weight: .semibold)); Text("关注一个主题，AI 自动收集相关文章。").font(.system(size: 12)).foregroundStyle(.secondary) }
            Spacer()
            Text("+ 新建").font(.system(size: 12)).foregroundStyle(.green)
        }.padding(12).liquidGlass()
    }

    private func folderSection(_ folder: Folder) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                if collapsedFolders.contains(folder.name) { collapsedFolders.remove(folder.name) } else { collapsedFolders.insert(folder.name) }
            } label: {
                HStack {
                    Image(systemName: "folder").font(.system(size: 13))
                    Text(folder.name).font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text("\(folder.feeds.reduce(0) { $0 + $1.unreadCount })").font(.system(size: 13)).foregroundStyle(.secondary)
                    Image(systemName: collapsedFolders.contains(folder.name) ? "chevron.right" : "chevron.down").font(.system(size: 11)).foregroundStyle(.secondary)
                }
            }.buttonStyle(.plain)
            if !collapsedFolders.contains(folder.name) {
                ForEach(folder.feeds) { feed in feedRow(feed) }
            }
        }
    }

    private func feedRow(_ feed: Feed) -> some View {
        HStack(spacing: 8) {
            FeedIconView(title: feed.title)
            Text(feed.title).font(.system(size: 14)).lineLimit(1)
            Spacer()
            Text("\(feed.unreadCount)").font(.system(size: 13)).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 7).padding(.horizontal, 4)
    }
}
