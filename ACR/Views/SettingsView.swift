import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var providers: [AIProvider]
    @Query private var feeds: [Feed]
    @AppStorage("appLanguage") private var language = "zh"
    @AppStorage("isDarkMode") private var isDark = false
    @AppStorage("dynamicBackground") private var dynamicBackground = false
    @AppStorage("dailyPushEnabled") private var dailyPushEnabled = false
    @AppStorage("pushHour") private var pushHour = 8
    @AppStorage("pushMinute") private var pushMinute = 0
    @AppStorage("icloudSyncEnabled") private var icloudSyncEnabled = true
    @AppStorage("briefingEnabled") private var briefingEnabled = true
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showLogin = false
    @State private var newFeedURL = ""
    @State private var addMessage = ""
    @State private var showProviderForm = false
    @State private var pName = "", pBase = "", pModel = "", pKey = ""
    @State private var showOPML = false

    var body: some View {
        NavigationStack {
            ZStack { DynamicBackground(); Form {
                Section {
                    Button { showLogin = true } label: {
                        HStack {
                            Image(systemName: "person.circle").font(.system(size: 28)).foregroundStyle(.teal)
                            VStack(alignment: .leading) {
                                Text(isLoggedIn ? "已登录 · 同步已开启" : I18n.t("account", lang: language)).font(.system(size: 15, weight: .semibold))
                                Text(isLoggedIn ? "订阅、收藏与阅读进度通过 iCloud 同步" : I18n.t("local_mode", lang: language)).font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer(); Text(I18n.t("login_register", lang: language)).font(.system(size: 12)).foregroundStyle(.green)
                        }
                    }
                }
                Section("iCloud 同步") {
                    Toggle(I18n.t("icloud_sync", lang: language), isOn: $icloudSyncEnabled)
                    Text("订阅、收藏、阅读进度、稍后读通过 iCloud 同步到其他设备。数据只放本机 + iCloud，不建服务器。").font(.system(size: 12)).foregroundStyle(.secondary)
                    HStack { Text("上次同步"); Spacer(); Text("刚刚").foregroundStyle(.secondary).font(.system(size: 13)) }
                    Button("立即同步") {}
                }
                Section("功能") {
                    Picker(I18n.t("language", lang: language), selection: $language) { Text("中文").tag("zh"); Text("English").tag("en") }.pickerStyle(.segmented)
                    Toggle("深色模式", isOn: $isDark)
                    Toggle("今日 AI 简报", isOn: $briefingEnabled)
                }
                Section("外观") {
                    Toggle(I18n.t("dynamic_bg", lang: language), isOn: $dynamicBackground)
                    Text(dynamicBackground ? "已开启：色彩缓慢流动" : "已关闭").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Section("每日推送") {
                    Toggle(I18n.t("daily_push", lang: language), isOn: $dailyPushEnabled)
                        .onChange(of: dailyPushEnabled) { _, on in
                            if on { NotificationService.scheduleDailyBriefing(hour: pushHour, minute: pushMinute) } else { NotificationService.cancelDailyBriefing() }
                        }
                    HStack {
                        Text("发送时间"); Spacer()
                        Picker("时", selection: $pushHour) { ForEach(0..<24, id: \.self) { Text("\($0) 时").tag($0) } }.pickerStyle(.menu).disabled(!dailyPushEnabled)
                        Picker("分", selection: $pushMinute) { ForEach([0, 15, 30, 45], id: \.self) { Text("\($0) 分").tag($0) } }.pickerStyle(.menu).disabled(!dailyPushEnabled)
                    }
                    Text(dailyPushEnabled ? "简报会在每天 \(String(format: "%02d:%02d", pushHour, pushMinute)) 推送到你的手机" : "每日推送已关闭").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Section(I18n.t("add_feed", lang: language)) {
                    TextField("粘贴网址，自动探测 RSS / Atom", text: $newFeedURL).textInputAutocapitalization(.never).autocorrectionDisabled()
                    Button("探测并添加") { Task { await addFeed() } }
                    NavigationLink { DiscoverView() } label: { Label(I18n.t("discover", lang: language), systemImage: "safari") }
                    if !addMessage.isEmpty { Text(addMessage).font(.system(size: 12)).foregroundStyle(.secondary) }
                    Button("导出 OPML") { showOPML = true }
                    Button("清理缓存（仅删除已读文章正文缓存）", role: .destructive) { clearCache() }
                }
                Section(I18n.t("ai_providers", lang: language)) {
                    ForEach(providers) { p in
                        HStack { Text(p.name).font(.system(size: 14)); Spacer(); Text(p.model).font(.system(size: 12)).foregroundStyle(.secondary); if p.isDefault { Text("默认").font(.system(size: 11)).foregroundStyle(.green) } }
                    }
                    Button("添加提供商") { showProviderForm = true }
                }
                Section { Text("Acr v1 · 本机数据 · 无广告").font(.system(size: 12)).foregroundStyle(.secondary) }
            }}
            .navigationTitle(I18n.t("settings", lang: language))
            .sheet(isPresented: $showLogin) { LoginView() }
            .sheet(isPresented: $showProviderForm) { providerForm }
            .sheet(isPresented: $showOPML) {
                ShareLink(item: OPMLService.export(feeds: feeds), preview: SharePreview("ACR OPML", image: Image(systemName: "square.and.arrow.up")))
            }
        }
    }

    private var providerForm: some View {
        NavigationStack {
            Form {
                TextField("名称，如 DeepSeek", text: $pName)
                TextField("Base URL，如 https://api.deepseek.com/v1", text: $pBase).textInputAutocapitalization(.never).autocorrectionDisabled()
                TextField("模型，如 deepseek-chat", text: $pModel).textInputAutocapitalization(.never).autocorrectionDisabled()
                SecureField("API Key（只存本机）", text: $pKey)
            }
            .navigationTitle("添加提供商")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        context.insert(AIProvider(name: pName.isEmpty ? "未命名" : pName, baseURL: pBase, model: pModel, apiKey: pKey, isDefault: providers.isEmpty))
                        try? context.save(); showProviderForm = false; pName = ""; pBase = ""; pModel = ""; pKey = ""
                    }
                }
                ToolbarItem(placement: .cancellationAction) { Button("取消") { showProviderForm = false } }
            }
        }
    }

    private func addFeed() async {
        guard let url = await FeedService.discoverFeedURL(from: newFeedURL) else { addMessage = "未探测到订阅源，请检查网址。"; return }
        let feed = Feed(title: url.absoluteString, url: url.absoluteString, siteURL: newFeedURL)
        context.insert(feed); try? context.save()
        await FeedService().refresh(feed: feed, context: context)
        addMessage = "已添加：\(feed.title)"; newFeedURL = ""
    }

    private func clearCache() {
        for a in feeds.flatMap({ $0.articles }).filter({ $0.isRead }) { a.content = "" }
        try? context.save()
    }
}
