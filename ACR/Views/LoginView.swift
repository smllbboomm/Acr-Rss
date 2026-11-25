import SwiftUI

/// 首次打开流程：请求网络权限 → 登录/注册 → 开始阅读；不登录也能用本机模式。
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var mode = 0 // 0 登录 1 注册
    @State private var account = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var networkGranted = false
    @State private var requesting = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("首次打开").font(.headline)
                stepRow(n: 1, title: "允许网络权限", done: networkGranted)
                stepRow(n: 2, title: "登录 / 注册", done: isLoggedIn)
                stepRow(n: 3, title: "开始阅读", done: false)
                if !networkGranted {
                    Button(requesting ? "请求中…" : "允许网络权限") {
                        requesting = true
                        Task { _ = await NotificationService.requestAuthorization(); networkGranted = true; requesting = false }
                    }.buttonStyle(.borderedProminent)
                }
                Picker("模式", selection: $mode) { Text("登录").tag(0); Text("注册").tag(1) }.pickerStyle(.segmented).disabled(!networkGranted)
                TextField("手机号或邮箱", text: $account).textInputAutocapitalization(.never).autocorrectionDisabled().textFieldStyle(.roundedBorder)
                SecureField("密码", text: $password).textFieldStyle(.roundedBorder)
                if mode == 1 { TextField("昵称", text: $nickname).textFieldStyle(.roundedBorder) }
                Button(mode == 0 ? "登录" : "注册") {
                    // v1 本地演示：账号只存本机，不连服务器；真实后端接入后在此替换为网络请求。
                    guard !account.isEmpty, !password.isEmpty else { return }
                    isLoggedIn = true; dismiss()
                }
                .buttonStyle(.borderedProminent).disabled(!networkGranted)
                Button("先不登录，用本机模式") { dismiss() }.foregroundStyle(.secondary)
                Spacer()
                Text("账号可选；登录后订阅、收藏与阅读进度通过 iCloud 同步。").font(.system(size: 12)).foregroundStyle(.secondary)
            }
            .padding(20)
            .navigationTitle("账号")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } } }
        }
    }

    private func stepRow(n: Int, title: String, done: Bool) -> some View {
        HStack { Image(systemName: done ? "checkmark.circle.fill" : "circle").foregroundStyle(done ? .green : .secondary); Text(title).font(.system(size: 14)) }
    }
}
