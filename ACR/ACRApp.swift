import SwiftUI
import SwiftData

@main
struct ACRApp: App {
    @AppStorage("appLanguage") private var language = "zh"
    @AppStorage("isDarkMode") private var isDark = false
    @AppStorage("dynamicBackground") private var dynamicBackground = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDark ? .dark : .light)
                .environment(\.locale, Locale(identifier: language == "en" ? "en" : "zh-Hans"))
        }
        .modelContainer(for: [Feed.self, Folder.self, Article.self, AIProvider.self])
    }
}

struct ContentView: View {
    @AppStorage("tabBarCollapsed") private var collapsed = false
    @State private var selection = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                TodayView().tabItem { Label("today_tab", systemImage: "sun.max") }.tag(0)
                LibraryView().tabItem { Label("library_tab", systemImage: "dot.radiowaves.left.and.right") }.tag(1)
                AskAIView().tabItem { Label("Ask AI", systemImage: "sparkles") }.tag(2)
                SettingsView().tabItem { Label("settings_tab", systemImage: "slider.horizontal.3") }.tag(3)
            }
            .tabViewStyle(.automatic)
            if collapsed {
                Button { collapsed = false } label: {
                    Image(systemName: ["sun.max", "dot.radiowaves.left.and.right", "sparkles", "slider.horizontal.3"][selection])
                        .font(.system(size: 25))
                }
                .frame(width: 49, height: 49)
                .liquidGlassCircle()
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Simple flat style (user decided: simple, no liquid glass)
extension View {
    func liquidGlass() -> some View {
        self.background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }
    func liquidGlassCircle() -> some View {
        self.background(Color(.secondarySystemBackground), in: Circle())
    }
}
