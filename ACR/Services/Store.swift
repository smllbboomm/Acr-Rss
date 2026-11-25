import Foundation
import SwiftUI

/// 应用级偏好（UserDefaults），与设计稿设置页一一对应。
final class AppSettings: ObservableObject {
    @AppStorage("isDarkMode") var isDark = false
    @AppStorage("appLanguage") var language = "zh" // zh / en
    @AppStorage("dynamicBackground") var dynamicBackground = false
    @AppStorage("dailyPushEnabled") var dailyPushEnabled = false
    @AppStorage("pushHour") var pushHour = 8
    @AppStorage("pushMinute") var pushMinute = 0
    @AppStorage("briefingEnabled") var briefingEnabled = true
    @AppStorage("icloudSyncEnabled") var icloudSyncEnabled = true
    @AppStorage("readerFontSize") var readerFontSize = 15.0
    @AppStorage("readerFont") var readerFont = "system"
    @AppStorage("aiSummaryEnabled") var aiSummaryEnabled = true
    @AppStorage("translateEnabled") var translateEnabled = false

    var pushTimeString: String { String(format: "%02d:%02d", pushHour, pushMinute) }
}
