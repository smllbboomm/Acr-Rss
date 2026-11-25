# ACR — 自用 iOS RSS 阅读器（v1）

> 注意：工程/Target 名是 ACR，Bundle ID 是 `com.smllbboomm.acr`，但手机桌面上显示的名字是 **Acr**（首字母大写、其余小写）。

对标清阅 RSS（Breeze Feeds），只看中文博客、新闻，自己用。
iOS 26 液态玻璃风格，底部四栏：今日 / 订阅 / Ask AI / 设置。
数据只放本机 + iCloud 同步，不建服务器；账号登录可选。

## 功能（v1 已实现）
- 今日：顶部 AI 简报卡（按主题分组、日期、三点菜单重新生成/关闭）
- 订阅：搜索栏、未读/收藏/稍后读统计、Topics 卡、分组（新建/展开收起）、20px 小图标紧凑列表
- 阅读：标题下 AI 总结、读到底上滑下一篇、阅读设定面板（字号/字体/深色/翻译）
- Ask AI：Ask about your articles、三建议问题、底部 All Articles 输入框
- 设置：账号登录入口（首次打开先请求网络权限）、iCloud 同步开关、本机缓存、语言中文/English、动态背景开关、每日推送开关+时间（默认 08:00）、添加订阅、发现页（12 个国内常用源点选+全选）、AI 提供商（可添加多家）
- 服务：RSS/Atom 解析（XMLParser）、粘贴网址自动探测 feed、OPML 导入导出、ETag / Last-Modified 条件请求

## 未实现 / 需付费账号才有
- 真实 AI 调用：AIService 已写好 OpenAI 兼容接口调用骨架，但默认不带任何 Key，需用户在设置里自填各提供商的 Key、Base URL、模型名；不填则 AI 总结/简报显示本地占位文案。
- 真实推送通知：本地通知骨架在 `Services/NotificationService.swift`（UNUserNotificationCenter），但每日定时推送在免费自签下不可靠，上架/TestFlight 需付费开发者账号才能稳定使用；v1 默认只做应用内简报。
- iCloud 同步：用 CloudKit / NSPersistentCloudKitContainer 需在 Xcode Capabilities 里开启 iCloud + CloudKit，并用付费账号签名；代码里已用 SwiftData ModelContainer，同步开关为 UI + 本地标记，真实 CloudKit 容器需在 Xcode 里配置后才生效。
- 上架 App Store / TestFlight：需 Apple Developer Program（中国大陆 688 元/年），免费 Apple ID 只能 AltStore 自签 7 天。

## 推送到 GitHub（smllbboomm）
```bash
cd ~/workspace/rss-reader-ios
git init
git add .
git commit -m "ACR v1"
git branch -M main
git remote add origin https://github.com/smllbboomm/acr.git
git push -u origin main
```
仓库名可改，上面只是示例；若仓库已存在，跳过 `git init`，直接 `git remote add` 后 push。

## GitHub Actions 编译取 IPA
1. push 后打开仓库 Actions → build-ipa。
2. 等绿色通过，点进那次运行 → Artifacts → 下载 `ACR-unsigned.ipa`。
3. 每次改代码 push 都会重新编译。macOS runner 免费额度约 200 分钟/月（macOS 按 10 倍计），一次编译约 5–10 分钟。

## Windows + iPhone 安装（AltStore 自签）
1. Windows 安装 AltServer（官网 altstore.io），再装苹果官网版 iTunes 和 iCloud（不是微软商店版）。
2. iPhone 连 USB，AltServer → Install AltStore，手机设置 → 通用 → VPN 与设备管理信任证书。
3. 把下载的 IPA 发到 AltStore 里（或用 AltServer 安装），用免费 Apple ID 签名安装。
4. 免费证书 7 天过期：AltServer 在同一 Wi-Fi 下开着会自动续签；过期重装即可。同一 Apple ID 最多同时 3 个自签 App。

## AI 提供商
设置 → AI 提供商 → 添加提供商，填名称、Base URL、模型、API Key。Key 只存本机钥匙串/本地，不进代码、不进 Git。

## 发现源地址说明
`Views/DiscoverView.swift` 与 `Services/SeedData.swift` 里的 12 个源：阮一峰、少数派、小众软件、爱范儿、机器之心、IT之家 6 个为公开常用地址；澎湃新闻、财新网、界面新闻、36氪、虎嗅网、南方周末 6 个地址以注释标注“待核实”，若打不开请在发现页用粘贴网址自动探测替换。
