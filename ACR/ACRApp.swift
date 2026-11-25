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

// MARK: - Liquid Glass (iOS 26, fallback to material)
extension View {
    @ViewBuilder
    func liquidGlass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(.white.opacity(0.15)), in: .rect(cornerRadius: 20))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    @ViewBuilder
    func liquidGlassCircle() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(.white.opacity(0.2)), in: .circle)
        } else {
            self.background(.ultraThinMaterial, in: Circle())
        }
    }
}
