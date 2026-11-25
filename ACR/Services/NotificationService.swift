import Foundation
import UserNotifications

/// 每日简报本地通知骨架。免费自签下定时推送不可靠，真实推送需付费账号 + 服务端/APNs。
/// v1 仅注册权限并可预约一条本地通知；是否生效取决于系统与签名方式。
enum NotificationService {
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleDailyBriefing(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "今日简报"
        content.body = "今日 AI 简报已生成，打开看看。"
        var date = DateComponents(); date.hour = hour; date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let req = UNNotificationRequest(identifier: "daily-briefing", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    static func cancelDailyBriefing() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-briefing"])
    }
}
