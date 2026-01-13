# GeeNow

一款优雅的 iOS 信息聚合阅读器，采用原生 SwiftUI 构建，为你提供一站式的热点资讯、深度阅读和内容订阅体验。

## 功能特性

### 热榜
实时追踪 20+ 主流平台热点，支持多种布局模式：

- **列表模式** - 紧凑高效，快速浏览
- **卡片模式** - 沉浸式阅读体验
- **分类筛选** - 关注、最热、实时、国内、国际、科技、财经
- **源导航栏** - 快速定位到指定信息源
- **收藏关注** - 自定义你的信息流

**支持的热榜源：**

| 分类 | 来源 |
|------|------|
| 国内 | 微博热搜、知乎热榜、今日头条、抖音热榜、百度热搜、哔哩哔哩、虎扑、贴吧、豆瓣 |
| 科技 | V2EX、IT之家、稀土掘金、少数派、酷安、GitHub Trending、Hacker News、CNBeta |
| 财经 | 雪球、华尔街见闻、财联社、金十数据、36氪 |
| 国际 | 凤凰网、澎湃新闻 |

### 阅读
精选技术文章，支持分类和精选筛选：

- **全部** - 所有精选文章
- **AI** - 人工智能领域深度内容
- **前端** - Web 开发技术文章
- **后端** - 服务端技术分享
- **DevOps** - 运维与基础设施
- **精选模式** - 仅显示高分优质内容

### 订阅
完整的 RSS 订阅系统，支持 200+ 优质内容源：

**文章订阅 (170+)**
- 人工智能：OpenAI、Anthropic、DeepMind、机器之心、量子位、新智元等
- 大厂技术：GitHub、Meta、Google、腾讯技术、阿里技术、字节跳动、美团等
- 开发框架：Next.js、Node.js、Spring、Docker、MongoDB、Grafana 等
- 独立博客：阮一峰、云风、酷壳、编程随想等

**播客订阅 (10+)**
- 硅谷 101、Acquired、Latent Space、Lex Fridman、创业内幕等

**视频订阅 (25+)**
- 技术教育：Fireship、freeCodeCamp、ByteByteGo 等
- 访谈节目：Lex Fridman、Dwarkesh Patel、All-In Podcast、TED 等
- 创投频道：Y Combinator、a16z、Sequoia Capital 等

**推文订阅 (160+)**
- AI 公司：OpenAI、Anthropic、Google AI、DeepMind、Mistral 等
- AI 研究者：Sam Altman、Andrej Karpathy、Yann LeCun 等
- AI 工具：Cursor、Perplexity、Midjourney、Runway 等
- 科技领袖：Satya Nadella、Marc Andreessen、Paul Graham 等
- 中文 KOL：宝玉、李继刚、歸藏、向阳乔木等

## 技术特性

- 原生 SwiftUI 开发，流畅动画体验
- MVVM 架构，代码清晰易维护
- Swift Concurrency 异步并发，高性能加载
- 智能缓存机制，15 分钟自动过期
- 失败保护，网络异常不丢失已有数据
- 深色模式自动适配
- 下拉刷新 + 上拉加载更多
- 内置音频播放器，支持播客后台播放
- YouTube 视频内嵌播放（Safari View）

## 系统要求

- iOS 17.0+
- Xcode 15.0+

## 项目结构

```
GeeNow/
├── App/                    # 应用入口
├── Models/                 # 数据模型
│   ├── Source.swift       # 热榜源定义
│   ├── NewsItem.swift     # 热榜条目
│   ├── RSSSource.swift    # RSS 源定义
│   ├── RSSArticle.swift   # 阅读文章
│   └── SubscriptionItem.swift  # 订阅内容
├── Data/
│   └── RSSSourceData.swift # 200+ RSS 源数据
├── Services/
│   ├── NewsService.swift   # 热榜服务
│   ├── RSSFeedService.swift # RSS 解析服务
│   ├── CacheService.swift  # 缓存服务
│   ├── AudioPlayerManager.swift # 音频播放
│   ├── SubscriptionManager.swift # 订阅管理
│   └── Sources/            # 24 个热榜源爬虫
├── ViewModels/
│   ├── HomeViewModel.swift
│   └── ReadingViewModel.swift
└── Views/
    ├── Components/         # 可复用组件
    │   ├── NewsCard.swift
    │   ├── CategoryTabBar.swift
    │   ├── FilterTabBar.swift
    │   ├── AudioPlayerView.swift
    │   └── VideoPlayerView.swift
    └── Screens/            # 页面
        ├── HomeScreen.swift      # 热榜
        ├── ReadingScreen.swift   # 阅读
        ├── SubscriptionScreen.swift # 订阅
        └── SettingsScreen.swift  # 设置
```

## 开发指南

### 运行项目

1. 使用 Xcode 15+ 打开 `GeeNow.xcodeproj`
2. 选择模拟器或真机
3. `Cmd + R` 运行

### 添加热榜源

在 `Services/Sources/` 创建新的源文件，实现 `NewsSourceProtocol`：

```swift
struct MySource: NewsSourceProtocol {
    let source = Source(
        id: "mysource",
        name: "我的源",
        colorName: "blue",
        type: .hottest,
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        // 实现抓取逻辑
    }
}
```

### 添加 RSS 订阅源

在 `Data/RSSSourceData.swift` 中添加：

```swift
RSSSource(
    id: "my-rss",
    name: "我的 RSS",
    feedURL: "https://example.com/feed.xml",
    type: .article,      // .article / .podcast / .video / .twitter
    category: .ai,       // 分类
    language: .chinese   // .chinese / .english
)
```

## 许可证

MIT License
