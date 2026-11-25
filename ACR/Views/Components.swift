import SwiftUI

/// 动态背景：四团柔和色彩缓慢流动；减弱动态效果时静止。
struct DynamicBackground: View {
    @AppStorage("dynamicBackground") private var enabled = false
    @State private var animate = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal.opacity(0.12), .blue.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
            if enabled {
                Circle().fill(Color.teal.opacity(0.35)).frame(width: 220).blur(radius: 26).offset(x: animate ? 60 : -60, y: animate ? -40 : 40)
                Circle().fill(Color.blue.opacity(0.30)).frame(width: 180).blur(radius: 26).offset(x: animate ? -70 : 50, y: animate ? 50 : -30)
                Circle().fill(Color.yellow.opacity(0.25)).frame(width: 160).blur(radius: 26).offset(x: animate ? 40 : -40, y: animate ? 60 : -50)
                Circle().fill(Color.pink.opacity(0.25)).frame(width: 150).blur(radius: 26).offset(x: animate ? -30 : 60, y: animate ? -60 : 50)
            }
        }
        .ignoresSafeArea()
        .onAppear { withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) { animate.toggle() } }
        .accessibilityReduceMotion(.reduce)
    }
}

struct FeedIconView: View {
    let title: String
    var body: some View {
        Text(String(title.prefix(1)))
            .font(.system(size: 11, weight: .bold))
            .frame(width: 20, height: 20)
            .background(Color.teal.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct StatCard: View {
    let icon: String; let count: Int; let label: String
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) { Image(systemName: icon).font(.system(size: 13)); Text("\(count)").font(.system(size: 17, weight: .semibold)) }
            Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10).liquidGlass()
    }
}
