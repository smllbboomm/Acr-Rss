import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(\.modelContext) private var context
    @Query private var existingFeeds: [Feed]
    @State private var selected: Set<String> = []

    var body: some View {
        List {
            Section {
                HStack {
                    Button("全选") { selected = Set(SeedData.discoverFeeds.map { $0.feedURL }) }
                    Spacer()
                    Button("清空") { selected.removeAll() }
                }
            }
            Section("国内常用源") {
                ForEach(SeedData.discoverFeeds) { s in
                    Toggle(isOn: Binding(get: { selected.contains(s.feedURL) }, set: { on in
                        if on { selected.insert(s.feedURL) } else { selected.remove(s.feedURL) }
                    })) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.title).font(.system(size: 14))
                            Text(s.verified ? s.siteURL : "地址待核实，打不开请用粘贴网址探测").font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                Button("添加所选（\(selected.count) 个）") { addSelected() }.disabled(selected.isEmpty)
                Text("不用一个个找地址，勾选要的就行。").font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("发现")
        .onAppear { selected = Set(existingFeeds.map { $0.url }) }
    }

    private func addSelected() {
        for s in SeedData.discoverFeeds where selected.contains(s.feedURL) {
            guard !existingFeeds.contains(where: { $0.url == s.feedURL }) else { continue }
            let folder = fetchOrCreateFolder(named: s.folder)
            context.insert(Feed(title: s.title, url: s.feedURL, siteURL: s.siteURL, iconName: String(s.title.prefix(1)), folder: folder))
        }
        try? context.save()
    }

    private func fetchOrCreateFolder(named name: String) -> Folder {
        let desc = FetchDescriptor<Folder>(predicate: #Predicate { $0.name == name })
        if let f = try? context.fetch(desc).first { return f }
        let f = Folder(name: name, sortOrder: 0); context.insert(f); return f
    }
}
