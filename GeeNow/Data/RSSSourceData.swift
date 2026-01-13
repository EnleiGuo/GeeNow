import Foundation

struct RSSSourceData {
    
    static let defaultSubscribedSourceIds: Set<String> = [
        "jiqizhixin",
        "guigu101-podcast"
    ]
    
    static let allSources: [RSSSource] = articleSources + podcastSources + videoSources + twitterSources
    
    static func sources(for type: RSSSourceType) -> [RSSSource] {
        allSources.filter { $0.type == type }
    }
    
    static func sources(for category: RSSSourceCategory) -> [RSSSource] {
        allSources.filter { $0.category == category }
    }
    
    static func groupedByCategory(for type: RSSSourceType) -> [(category: RSSSourceCategory, sources: [RSSSource])] {
        let filtered = sources(for: type)
        let grouped = Dictionary(grouping: filtered) { $0.category }
        return grouped.map { (category: $0.key, sources: $0.value) }
            .sorted { $0.sources.count > $1.sources.count }
    }
    
    // MARK: - Article Sources (170个)
    
    static let articleSources: [RSSSource] = [
        // 人工智能 - 国际
        RSSSource(id: "openai-blog", name: "OpenAI Blog", feedURL: "https://openai.com/news/rss.xml", type: .article, category: .ai, language: .english),
        RSSSource(id: "langchain-blog", name: "LangChain Blog", feedURL: "https://blog.langchain.dev/rss/", type: .article, category: .ai, language: .english),
        RSSSource(id: "huggingface-blog", name: "Hugging Face Blog", feedURL: "https://huggingface.co/blog/feed.xml", type: .article, category: .ai, language: .english),
        RSSSource(id: "deepmind-blog", name: "Google DeepMind Blog", feedURL: "https://deepmind.com/blog/feed/basic/", type: .article, category: .ai, language: .english),
        RSSSource(id: "anthropic-news", name: "Anthropic News", feedURL: "https://rsshub.bestblogs.dev/anthropic/news", type: .article, category: .ai, language: .english),
        RSSSource(id: "aws-ml-blog", name: "AWS Machine Learning Blog", feedURL: "https://aws.amazon.com/blogs/amazon-ai/feed/", type: .article, category: .ai, language: .english),
        RSSSource(id: "meta-ai-blog", name: "AI at Meta Blog", feedURL: "https://rsshub.app/meta/ai/blog", type: .article, category: .ai, language: .english),
        RSSSource(id: "deeplearning-ai", name: "deeplearning.ai", feedURL: "https://rsshub.bestblogs.dev/deeplearning/the-batch", type: .article, category: .ai, language: .english),
        RSSSource(id: "last-week-in-ai", name: "Last Week in AI", feedURL: "https://lastweekin.ai/feed/", type: .article, category: .ai, language: .english),
        RSSSource(id: "latent-space", name: "Latent Space", feedURL: "https://www.latent.space/feed", type: .article, category: .ai, language: .english),
        RSSSource(id: "llamaindex-blog", name: "LlamaIndex Blog", feedURL: "https://www.llamaindex.ai/blog/feed", type: .article, category: .ai, language: .english),
        RSSSource(id: "qdrant-blog", name: "Qdrant", feedURL: "https://qdrant.tech/index.xml", type: .article, category: .ai, language: .english),
        RSSSource(id: "groq-blog", name: "Groq", feedURL: "https://api.bestblogs.dev/feed/groqBlog", type: .article, category: .ai, language: .english),
        RSSSource(id: "elevenlabs-blog", name: "ElevenLabs Blog", feedURL: "https://api.bestblogs.dev/feed/elevenLabsBlog", type: .article, category: .ai, language: .english),
        RSSSource(id: "firecrawl-blog", name: "FireCrawl Blog", feedURL: "https://api.bestblogs.dev/feed/fireCrawlBlog", type: .article, category: .ai, language: .english),
        
        // 人工智能 - 中文
        RSSSource(id: "jiqizhixin", name: "机器之心", feedURL: "https://wechat2rss.bestblogs.dev/feed/8d97af31b0de9e48da74558af128a4673d78c9a3.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "liangziwei", name: "量子位", feedURL: "https://www.qbitai.com/feed", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "xinzhiyuan", name: "新智元", feedURL: "https://wechat2rss.bestblogs.dev/feed/e531a18b21c34cf787b83ab444eef659d7a980de.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "ai-qianxian", name: "AI前线", feedURL: "https://wechat2rss.bestblogs.dev/feed/25185b01482da0f485418ecb92e208b4416712fb.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "showmeai", name: "ShowMeAI研究中心", feedURL: "https://wechat2rss.bestblogs.dev/feed/854a592a3bac3c2574d092daf4628cf65dfd1858.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "zhipu", name: "智谱", feedURL: "https://wechat2rss.bestblogs.dev/feed/433d2134dca54d80804daf32e8be546155be3300.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "kimi", name: "月之暗面 Kimi", feedURL: "https://wechat2rss.bestblogs.dev/feed/c5c43d4bc17bae656763859ed0903bb6314ec6fe.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "tongyi", name: "通义大模型", feedURL: "https://wechat2rss.bestblogs.dev/feed/4ebee6222ae08705b8aabc9116f0defbcb6b17c6.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "baidu-ai", name: "百度AI", feedURL: "https://wechat2rss.bestblogs.dev/feed/d0767d885e6ba213344fb0c0408c51331e23a994.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "hunyuan", name: "腾讯混元", feedURL: "https://wechat2rss.bestblogs.dev/feed/306ce19a1ca590c9c2df781789e828d1acfa1356.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "deepseek", name: "DeepSeek", feedURL: "https://wechat2rss.bestblogs.dev/feed/1709da4f538d4ce4fb6d7a8ba1a5a1c297919601.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "jieyue", name: "阶跃星辰", feedURL: "https://wechat2rss.bestblogs.dev/feed/3e2714d06aa36142e8ed6b3f4e5cf9090a069dd2.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "minimax", name: "MiniMax 稀宇科技", feedURL: "https://wechat2rss.bestblogs.dev/feed/00306b171f754d463b28cf83f3ba086ad009b430.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "bytedance-seed", name: "字节跳动Seed", feedURL: "https://wechat2rss.bestblogs.dev/feed/6efd40bb335d2037f365d284cb5e00f0843e737e.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "moda", name: "魔搭ModelScope社区", feedURL: "https://wechat2rss.bestblogs.dev/feed/d993a885260f96057b9a4c96212cb2c95bb5054b.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "dify-wechat", name: "Dify", feedURL: "https://wechat2rss.bestblogs.dev/feed/e46c03a4cb65509e22ab9a8507888a2096319d65.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "jina-ai", name: "Jina AI", feedURL: "https://wechat2rss.bestblogs.dev/feed/ff2c5468828ebe7236afd6c1d128e219774487c2.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "datawhale", name: "Datawhale", feedURL: "https://wechat2rss.bestblogs.dev/feed/ea0dd8bddfe4fbfb32eaa81a1e1b628d45e97a80.xml", type: .article, category: .ai, language: .chinese),
        RSSSource(id: "ainlp", name: "AINLP", feedURL: "https://wechat2rss.bestblogs.dev/feed/875df1d1a991bf9250ba9813e3148f58ef2240d4.xml", type: .article, category: .ai, language: .chinese),
        
        // 大厂技术
        RSSSource(id: "github-blog", name: "The GitHub Blog", feedURL: "https://github.blog/feed/", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "meta-eng", name: "Engineering at Meta", feedURL: "https://engineering.fb.com/feed/", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "google-cloud", name: "Google Cloud Blog", feedURL: "https://cloudblog.withgoogle.com/rss/", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "google-dev", name: "Google Developers Blog", feedURL: "https://developers.googleblog.com/feeds/posts/default", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "azure-blog", name: "Microsoft Azure Blog", feedURL: "https://azure.microsoft.com/en-us/blog/feed/", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "ms-research", name: "Microsoft Research Blog", feedURL: "http://research.microsoft.com/rss/news.xml", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "cloudflare-blog", name: "The Cloudflare Blog", feedURL: "https://blog.cloudflare.com/rss", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "vercel-news", name: "Vercel News", feedURL: "https://vercel.com/atom", type: .article, category: .bigTech, language: .english),
        RSSSource(id: "tencent-tech", name: "腾讯技术工程", feedURL: "https://wechat2rss.bestblogs.dev/feed/1e0ac39f8952b2e7f0807313cf2633d25078a171.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "tencent-cloud-dev", name: "腾讯云开发者", feedURL: "https://wechat2rss.bestblogs.dev/feed/6cec2c211479a5502896375860009782cf10c2ba.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "ali-tech", name: "阿里技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/6535a444e9651fecae3383363be7589acdebe2b6.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "ali-cloud-dev", name: "阿里云开发者", feedURL: "https://wechat2rss.bestblogs.dev/feed/39fc51b0b1316137e608c45da5dbbca4f9eb9538.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "taobao-tech", name: "大淘宝技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/26fef2307bebc8673703f7e726982d8f56c9a219.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "bytedance-tech", name: "字节跳动技术团队", feedURL: "https://wechat2rss.bestblogs.dev/feed/d3a9e4d6f125cc98d1691dbc30cd97fec7ae2d03.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "meituan-tech", name: "美团技术团队", feedURL: "https://tech.meituan.com/feed/", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "jd-tech", name: "京东技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/fa0be550682410cc187c0d1eab1a0fc4e073b949.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "baidu-geek", name: "百度Geek说", feedURL: "https://wechat2rss.bestblogs.dev/feed/6cc437d76f9dc4f7c35011c72e471e33e7bdd384.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "xiaomi-tech", name: "小米技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/8bbc1ba1d363e70cd42d1ce89fb9070cb075c3b3.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "bilibili-tech", name: "哔哩哔哩技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/3a12ae4fde5bb74aab2fddc9f710a3c057eab82f.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "dewu-tech", name: "得物技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/1cde72c9129b1f79cbb150166e7fed9a7568ee10.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "vivo-tech", name: "vivo互联网技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/b3ceb5cb1e4602ca55704650a157ec9c5b2f0d31.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "kuaishou-tech", name: "快手技术", feedURL: "https://wechat2rss.bestblogs.dev/feed/c4cc10d2e32a5fa12927581ae581a336f399fe75.xml", type: .article, category: .bigTech, language: .chinese),
        RSSSource(id: "xiaohongshu-tech", name: "小红书技术REDtech", feedURL: "https://wechat2rss.bestblogs.dev/feed/0f8c47df6fd304112518544776e0bbf1d98ba0b9.xml", type: .article, category: .bigTech, language: .chinese),
        
        // 开发工具/框架
        RSSSource(id: "nextjs-blog", name: "Next.js Blog", feedURL: "https://nextjs.org/feed.xml", type: .article, category: .tools, language: .english),
        RSSSource(id: "nodejs-blog", name: "Node.js Blog", feedURL: "https://nodejs.org/en/feed/blog.xml", type: .article, category: .tools, language: .english),
        RSSSource(id: "spring-blog", name: "Spring Blog", feedURL: "http://spring.io/blog.atom", type: .article, category: .tools, language: .english),
        RSSSource(id: "docker-blog", name: "Docker", feedURL: "https://www.docker.com/feed/", type: .article, category: .tools, language: .english),
        RSSSource(id: "mongodb-blog", name: "MongoDB Blog", feedURL: "https://www.mongodb.com/blog/rss", type: .article, category: .tools, language: .english),
        RSSSource(id: "elastic-blog", name: "Elastic Blog", feedURL: "https://www.elastic.co/blog/feed", type: .article, category: .tools, language: .english),
        RSSSource(id: "grafana-blog", name: "Grafana Labs", feedURL: "https://grafana.com/categories/engineering/index.xml", type: .article, category: .tools, language: .english),
        RSSSource(id: "jetbrains-blog", name: "The JetBrains Blog", feedURL: "http://blog.jetbrains.com/feed/", type: .article, category: .tools, language: .english),
        RSSSource(id: "intellij-blog", name: "The IntelliJ IDEA Blog", feedURL: "http://blogs.jetbrains.com/idea/feed/", type: .article, category: .tools, language: .english),
        RSSSource(id: "vs-blog", name: "Visual Studio Blog", feedURL: "https://devblogs.microsoft.com/visualstudio/feed/", type: .article, category: .tools, language: .english),
        RSSSource(id: "databricks-blog", name: "Databricks", feedURL: "https://www.databricks.com/feed", type: .article, category: .tools, language: .english),
        
        // 科技媒体
        RSSSource(id: "infoq", name: "InfoQ", feedURL: "http://www.infoq.com/rss/rss.action", type: .article, category: .media, language: .english),
        RSSSource(id: "freecodecamp", name: "freeCodeCamp.org", feedURL: "https://www.freecodecamp.org/news/rss/", type: .article, category: .media, language: .english),
        RSSSource(id: "stackoverflow-blog", name: "Stack Overflow Blog", feedURL: "http://blog.stackoverflow.com/feed/", type: .article, category: .media, language: .english),
        RSSSource(id: "ifanr", name: "爱范儿", feedURL: "http://www.ifanr.com/feed", type: .article, category: .media, language: .chinese),
        RSSSource(id: "geekpark", name: "极客公园", feedURL: "https://wechat2rss.bestblogs.dev/feed/11ea7163fbea99e2ab9fa2812ac3d179574886cc.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "tencent-tech-media", name: "腾讯科技", feedURL: "https://wechat2rss.bestblogs.dev/feed/a81bdfcbb9eefe870d285e81510ffa1af26e4520.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "netease-tech", name: "网易科技", feedURL: "https://wechat2rss.bestblogs.dev/feed/028fbc21062e744c7b606880ebca01e22cb4b7b7.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "zhidongxi", name: "智东西", feedURL: "https://wechat2rss.bestblogs.dev/feed/cfd52b4245ca6119b2fda4ef934832c689028927.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "latepost", name: "晚点LatePost", feedURL: "https://wechat2rss.bestblogs.dev/feed/c442206ec9957f3c52f2f40300ca532079538b31.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "jiaziguangnian", name: "甲子光年", feedURL: "https://wechat2rss.bestblogs.dev/feed/1c4008936645d5c17239d99bba91522cf2bdfa26.xml", type: .article, category: .media, language: .chinese),
        RSSSource(id: "infoq-cn", name: "InfoQ 中文", feedURL: "https://wechat2rss.bestblogs.dev/feed/13da94d7eb314b49fa251cb7e8399cae29d772db.xml", type: .article, category: .media, language: .chinese),
        
        // 个人博客/KOL
        RSSSource(id: "martin-fowler", name: "Martin Fowler", feedURL: "https://martinfowler.com/feed.atom", type: .article, category: .personal, language: .english),
        RSSSource(id: "dhh", name: "David Heinemeier Hansson", feedURL: "https://world.hey.com/dhh/feed.atom", type: .article, category: .personal, language: .english),
        RSSSource(id: "simon-willison", name: "Simon Willison's Weblog", feedURL: "https://simonwillison.net/atom/everything/", type: .article, category: .personal, language: .english),
        RSSSource(id: "bytebytego", name: "ByteByteGo Newsletter", feedURL: "https://blog.bytebytego.com/feed", type: .article, category: .personal, language: .english),
        RSSSource(id: "gino-notes", name: "Gino Notes", feedURL: "https://www.ginonotes.com/feed.xml", type: .article, category: .personal, language: .chinese),
        RSSSource(id: "ruanyifeng", name: "阮一峰的网络日志", feedURL: "http://feeds.feedburner.com/ruanyifeng", type: .article, category: .personal, language: .chinese),
        RSSSource(id: "baoyu", name: "宝玉的分享", feedURL: "https://baoyu.io/feed.xml", type: .article, category: .personal, language: .chinese),
        RSSSource(id: "lijigang", name: "李继刚", feedURL: "https://wechat2rss.bestblogs.dev/feed/9645a69180041ff935c458753174fa8bc2061295.xml", type: .article, category: .personal, language: .chinese),
        RSSSource(id: "liurun", name: "刘润", feedURL: "https://wechat2rss.bestblogs.dev/feed/c1354f67c314d25d6e236a58724043bdc46d6079.xml", type: .article, category: .personal, language: .chinese),
        RSSSource(id: "lxiansheng", name: "L先生说", feedURL: "https://wechat2rss.bestblogs.dev/feed/31c7fb6f7959a5ff90ae997b536e78b8b3f23321.xml", type: .article, category: .personal, language: .chinese),
        
        // 前端/设计
        RSSSource(id: "smashing", name: "Smashing Magazine", feedURL: "http://rss1.smashingmagazine.com/feed/", type: .article, category: .frontend, language: .english),
        RSSSource(id: "uxmag", name: "UX Magazine", feedURL: "https://uxmag.com/feed/", type: .article, category: .frontend, language: .english),
        RSSSource(id: "qiwujingxuan", name: "奇舞精选", feedURL: "https://wechat2rss.bestblogs.dev/feed/156a64fe3e95eebe4b85bf981d6ebb85441897bf.xml", type: .article, category: .frontend, language: .chinese),
        RSSSource(id: "qianduan-chongdianbao", name: "前端充电宝", feedURL: "https://wechat2rss.bestblogs.dev/feed/efed19b684285ee14f88b3f234b350fba9376d7a.xml", type: .article, category: .frontend, language: .chinese),
        RSSSource(id: "qianduan-zaoduke", name: "前端早读课", feedURL: "https://wechat2rss.bestblogs.dev/feed/ce2456e157156d42259c1198f05a33e27b1ed959.xml", type: .article, category: .frontend, language: .chinese),
        RSSSource(id: "youshe", name: "优设", feedURL: "https://wechat2rss.bestblogs.dev/feed/8fee9d33e883a769a59a5a3e27d249cf8567b55a.xml", type: .article, category: .frontend, language: .chinese),
        
        // 商业/创投
        RSSSource(id: "42zhangjing", name: "42章经", feedURL: "https://wechat2rss.bestblogs.dev/feed/f6694726ced4ba3d7c7cd65c6edf2160c5978387.xml", type: .article, category: .business, language: .chinese),
        RSSSource(id: "chuangyebang", name: "创业邦", feedURL: "https://wechat2rss.bestblogs.dev/feed/f5e0d8e342d9e2ec5b2942f08522cfaec17acc8d.xml", type: .article, category: .business, language: .chinese),
        RSSSource(id: "founder-park", name: "Founder Park", feedURL: "https://wechat2rss.bestblogs.dev/feed/f940695505f2be1399d23cc98182297cadf6f90d.xml", type: .article, category: .business, language: .chinese),
        RSSSource(id: "haiwai-dujiaoshou", name: "海外独角兽", feedURL: "https://wechat2rss.bestblogs.dev/feed/7200d3a5e976d231deb1e40ad33745c0e649b029.xml", type: .article, category: .business, language: .chinese),
        RSSSource(id: "jingwei", name: "经纬创投", feedURL: "https://wechat2rss.bestblogs.dev/feed/05efb1c4cf91e5a37443cc323150ea38a838e9fd.xml", type: .article, category: .business, language: .chinese),
        RSSSource(id: "zhenge", name: "真格基金", feedURL: "https://wechat2rss.bestblogs.dev/feed/47798a14d51da72e68fae4f7a259f096750cf03e.xml", type: .article, category: .business, language: .chinese),
        
        // 开源社区
        RSSSource(id: "juejin", name: "掘金本周最热", feedURL: "https://rsshub.bestblogs.dev/juejin/trending/all/weekly", type: .article, category: .openSource, language: .chinese),
        RSSSource(id: "hellogithub", name: "HelloGitHub", feedURL: "https://wechat2rss.bestblogs.dev/feed/e6cc80b97bf64eeef61cc5927c78ba6ce3356422.xml", type: .article, category: .openSource, language: .chinese),
        RSSSource(id: "juejin-wechat", name: "稀土掘金技术社区", feedURL: "https://wechat2rss.bestblogs.dev/feed/33ecd2122ae788ea02dfcf1df857a54b9ae1338d.xml", type: .article, category: .openSource, language: .chinese),
    ]
    
    // MARK: - Podcast Sources (31个)
    
    static let podcastSources: [RSSSource] = [
        // 科技播客
        RSSSource(id: "guigu101-podcast", name: "硅谷101", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5e5c52c9418a84a04625e6cc", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "whatsnext", name: "What's Next｜科技早知道", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5e74b52c418a84a046ecaceb", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "ai-lianjinshu-podcast", name: "AI炼金术", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/63e9ef4de99bdef7d39944c8", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "renmin-gongyuan", name: "人民公园说AI", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/65257ff6e8ce9deaf70a65e9", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "yingdi-haike", name: "硬地骇客", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/640ee2438be5d40013fe4a87", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "fengyan-fengyu", name: "枫言枫语", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5e2864f5418a84a04628e249", type: .podcast, category: .techPodcast, language: .chinese),
        RSSSource(id: "kaishi-lianjie", name: "开始连接LinkStart", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/63ff0da51b1faf8a0b70b337", type: .podcast, category: .techPodcast, language: .chinese),
        
        // 商业播客
        RSSSource(id: "wurenzhixiao", name: "无人知晓", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/611719d3cb0b82e1df0ad29e", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "sanwuhuan", name: "三五环", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5e280fab418a84a0461faa3c", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "zhangxiaojun", name: "张小珺Jùn｜商业访谈录", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/626b46ea9cbbf0451cf5a962", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "42zhangjing-podcast", name: "42章经", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/648b0b641c48983391a63f98", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "wandianliao", name: "晚点聊 LateTalk", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/61933ace1b4320461e91fd55", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "luanfanshu", name: "乱翻书", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/61358d971c5d56efe5bcb5d2", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "onboard", name: "OnBoard!", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/61cbaac48bb4cd867fcabe22", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "zongheng-sihai", name: "纵横四海", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/62694abdb221dd5908417d1e", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "ban-natie", name: "半拿铁 | 商业沉浮录", feedURL: "http://rsshub.bestblogs.dev/xiaoyuzhou/podcast/62382c1103bea1ebfffa1c00", type: .podcast, category: .businessPodcast, language: .chinese),
        RSSSource(id: "weishijie", name: "卫诗婕｜商业漫谈Jane's talk", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/6627fda4b56459544087d86a", type: .podcast, category: .businessPodcast, language: .chinese),
        
        // 生活播客
        RSSSource(id: "shizi-lukou", name: "十字路口Crossing", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/60502e253c92d4f62c2a9577", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "zhixing-xiaojiuguan", name: "知行小酒馆", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/6013f9f58e2f7ee375cf4216", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "baochi-pianjian", name: "保持偏见", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/663e3c95af1e22bb157dcee3", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "niuyouguo", name: "牛油果烤面包", feedURL: "http://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5e7c8b2b418a84a046e3ecbc", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "tianzhen", name: "天真不天真", feedURL: "http://rsshub.bestblogs.dev/xiaoyuzhou/podcast/65cef9e3cace72dff8d98de3", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "dongqiang-xidiao", name: "东腔西调", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/5f72b66083c34e85dd14fde9", type: .podcast, category: .lifePodcast, language: .chinese),
        RSSSource(id: "luoyonghao", name: "罗永浩的十字路口", feedURL: "https://rsshub.bestblogs.dev/xiaoyuzhou/podcast/68981df29e7bcd326eb91d88", type: .podcast, category: .lifePodcast, language: .chinese),
    ]
    
    // MARK: - Video Sources (41个)
    
    static let videoSources: [RSSSource] = [
        // AI 视频
        RSSSource(id: "yt-openai", name: "OpenAI", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCXZCJLdBC09xxGZ6gcdrc6A", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-anthropic", name: "Anthropic", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCrDwWp7EBBv4NwvScIpBDOA", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-deepmind", name: "Google DeepMind", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCP7jMXSY2xbc3KCAE0MHQ-A", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-ai-engineer", name: "AI Engineer", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCLKPca3kwwd-B59HNr-_lvA", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-karpathy", name: "Andrej Karpathy", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-langchain", name: "LangChain", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCC-lyoTfSrcJzA1ab3APAgw", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-two-minute", name: "Two Minute Papers", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCbfYPyITQ-7l4upoX8nvctg", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-ai-explained", name: "AI Explained", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCNJ1Ymd5yFuUPtn21xtRbbw", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-matthew-berman", name: "Matthew Berman", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCawZsQWqfGSbCI5yjkdVkTA", type: .video, category: .aiVideo, language: .english),
        RSSSource(id: "yt-matt-wolfe", name: "Matt Wolfe", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UChpleBmo18P08aKCIgti38g", type: .video, category: .aiVideo, language: .english),
        
        // 技术教育
        RSSSource(id: "yt-fireship", name: "Fireship", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCsBjURrPoezykLs9EqgamOA", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-freecodecamp", name: "freeCodeCamp.org", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC8butISFwT-Wl7EV0hUK0BQ", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-bytebytego", name: "ByteByteGo", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCZgt6AzoyjslHTC9dz0UoTw", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-hungyilee", name: "Hung-yi Lee", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC2ggjtuuWvxrHHHiaDH1dlQ", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-leerob", name: "leerob", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCZMli3czZnd1uoc1ShTouQw", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-tina-huang", name: "Tina Huang", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC2UXDak6o7rBm23k3Vv5dww", type: .video, category: .techVideo, language: .english),
        RSSSource(id: "yt-spring-io", name: "Spring I/O", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCLMPXsvSrhNPN3i9h-u8PYg", type: .video, category: .techVideo, language: .english),
        
        // 访谈节目
        RSSSource(id: "yt-lex", name: "Lex Fridman", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCSHZKyawb77ixDdsGog4iWA", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-dwarkesh", name: "Dwarkesh Patel", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCXl4i9dYBrFOabk0xGmbkRA", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-no-priors", name: "No Priors", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCSI7h9hydQ40K5MJHnCrQvw", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-lenny", name: "Lenny's Podcast", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC6t1O76G0jYXOAoYCm153dA", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-allin", name: "All-In Podcast", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCESLZhusAkFfsNsApnjF_Cg", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-diary-ceo", name: "The Diary Of A CEO Clips", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCnjgxChqYYnyoqO4k_Q1d6Q", type: .video, category: .interviewVideo, language: .english),
        RSSSource(id: "yt-ted", name: "TED", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCAuUUnT6oDeKwE6v1NGQxug", type: .video, category: .interviewVideo, language: .english),
        
        // VC/创投
        RSSSource(id: "yt-yc", name: "Y Combinator", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCcefcZRL2oaA_uBNeo5UOWg", type: .video, category: .vcVideo, language: .english),
        RSSSource(id: "yt-a16z", name: "a16z", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC9cn0TuPq4dnbTY-CBsm8XA", type: .video, category: .vcVideo, language: .english),
        RSSSource(id: "yt-sequoia", name: "Sequoia Capital", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCWrF0oN6unbXrWsTN7RctTw", type: .video, category: .vcVideo, language: .english),
        RSSSource(id: "yt-stripe", name: "Stripe", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UCM1guA1E-RHLO2OyfQPOkEQ", type: .video, category: .vcVideo, language: .english),
        RSSSource(id: "yt-product-school", name: "Product School", feedURL: "https://www.youtube.com/feeds/videos.xml?channel_id=UC6hlQ0x6kPbAGjYkoz53cvA", type: .video, category: .vcVideo, language: .english),
    ]
    
    // MARK: - Twitter Sources (161个)
    
    static let twitterSources: [RSSSource] = [
        // AI 公司
        RSSSource(id: "tw-openai", name: "OpenAI", feedURL: "https://api.xgo.ing/rss/user/0c0856a69f9f49cf961018c32a0b0049", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-chatgpt", name: "ChatGPT", feedURL: "https://api.xgo.ing/rss/user/f7992687b8d74b14bf2341eb3a0a5ec4", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-anthropic", name: "Anthropic", feedURL: "https://api.xgo.ing/rss/user/fc28a211471b496682feff329ec616e5", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-claude", name: "Claude", feedURL: "https://api.xgo.ing/rss/user/01f60d63a61b44d692cc35c7feb0b4a4", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-google-ai", name: "Google AI", feedURL: "https://api.xgo.ing/rss/user/4de0bd2d5cef4333a0260dc8157054a7", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-deepmind", name: "Google DeepMind", feedURL: "https://api.xgo.ing/rss/user/a99538443a484fcc846bdcc8f50745ec", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-meta-ai", name: "AI at Meta", feedURL: "https://api.xgo.ing/rss/user/ef7c70f9568d45f4915169fef4ce90b4", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-mistral", name: "Mistral AI", feedURL: "https://api.xgo.ing/rss/user/8d2d03aea8af49818096da4ea00409d1", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-xai", name: "xAI", feedURL: "https://api.xgo.ing/rss/user/3953aa71e87a422eb9d7bf6ff1c7c43e", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-nvidia-ai", name: "NVIDIA AI", feedURL: "https://api.xgo.ing/rss/user/05f1492e43514dc3862a076d3697c390", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-huggingface", name: "Hugging Face", feedURL: "https://api.xgo.ing/rss/user/fc16750ce50741f1b1f05ea1fb29436f", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-deepseek", name: "DeepSeek", feedURL: "https://api.xgo.ing/rss/user/68b610deb24b47ae9a236811563cda86", type: .twitter, category: .aiCompany, language: .english),
        RSSSource(id: "tw-qwen", name: "Qwen", feedURL: "https://api.xgo.ing/rss/user/80032d016d654eb4afe741ff34b7643d", type: .twitter, category: .aiCompany, language: .english),
        
        // AI 研究者
        RSSSource(id: "tw-sama", name: "Sam Altman", feedURL: "https://api.xgo.ing/rss/user/e30d4cd223f44bed9d404807105c8927", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-dario", name: "Dario Amodei", feedURL: "https://api.xgo.ing/rss/user/49666ce6fe3e4cb786c6574684542ec5", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-karpathy", name: "Andrej Karpathy", feedURL: "https://api.xgo.ing/rss/user/edf707b5c0b248579085f66d7a3c5524", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-ylecun", name: "Yann LeCun", feedURL: "https://api.xgo.ing/rss/user/f5f4f928dede472ea55053672ad27ab6", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-hinton", name: "Geoffrey Hinton", feedURL: "https://api.xgo.ing/rss/user/cb6169815e2e447e8e6148a4af3f9686", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-feifei", name: "Fei-Fei Li", feedURL: "https://api.xgo.ing/rss/user/a4bfe44bfc0d4c949da21ebd3f5f42a5", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-demis", name: "Demis Hassabis", feedURL: "https://api.xgo.ing/rss/user/4a884d5e2f3740c5a26c9c093de6388a", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-jeff-dean", name: "Jeff Dean", feedURL: "https://api.xgo.ing/rss/user/b1013166769c49f8aa3fbdc222867054", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-andrew-ng", name: "Andrew Ng", feedURL: "https://api.xgo.ing/rss/user/08b5488b20bc437c8bfc317a52e5c26d", type: .twitter, category: .aiResearcher, language: .english),
        RSSSource(id: "tw-jim-fan", name: "Jim Fan", feedURL: "https://api.xgo.ing/rss/user/c6cfe7c0d6b74849997073233fdea840", type: .twitter, category: .aiResearcher, language: .english),
        
        // AI 工具
        RSSSource(id: "tw-cursor", name: "Cursor", feedURL: "https://api.xgo.ing/rss/user/5287b4e0e13a4ab7ab7b1d56f9d88960", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-windsurf", name: "Windsurf", feedURL: "https://api.xgo.ing/rss/user/4a8273800ed34a069eecdb6c5c1b9ccf", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-replit", name: "Replit", feedURL: "https://api.xgo.ing/rss/user/613f859e4bc440c5a28f40732840f5cf", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-lovable", name: "Lovable", feedURL: "https://api.xgo.ing/rss/user/639cd13d44284e10ac89fbd1c5399767", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-bolt", name: "bolt.new", feedURL: "https://api.xgo.ing/rss/user/760ab7cd9708452c9ce1f9144b92a430", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-v0", name: "v0", feedURL: "https://api.xgo.ing/rss/user/dbf37973e6fc4eae91d4be9669a78fc7", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-perplexity", name: "Perplexity", feedURL: "https://api.xgo.ing/rss/user/fdd601ea751949e7bec9e4cdad7c8e6c", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-midjourney", name: "Midjourney", feedURL: "https://api.xgo.ing/rss/user/72dd496bfd9d44c5a5761a974630376d", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-runway", name: "Runway", feedURL: "https://api.xgo.ing/rss/user/e6bb4f612dd24db5bc1a6811e6dd5820", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-elevenlabs", name: "ElevenLabs", feedURL: "https://api.xgo.ing/rss/user/1897eed387064dfab443764d6da50bc6", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-langchain", name: "LangChain", feedURL: "https://api.xgo.ing/rss/user/862fee50a745423c87e2633b274caf1d", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-llamaindex", name: "LlamaIndex", feedURL: "https://api.xgo.ing/rss/user/67e259bd5be544ce84bbc867eace54c2", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-dify", name: "Dify", feedURL: "https://api.xgo.ing/rss/user/0be252fedbe84ad7bea21be44b18da89", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-ollama", name: "ollama", feedURL: "https://api.xgo.ing/rss/user/6326c63a2dfa445bbde88bea0c3112c2", type: .twitter, category: .aiTool, language: .english),
        RSSSource(id: "tw-firecrawl", name: "Firecrawl", feedURL: "https://api.xgo.ing/rss/user/c04abb206bbf4f91b22795024d6c0614", type: .twitter, category: .aiTool, language: .english),
        
        // 科技领袖
        RSSSource(id: "tw-satya", name: "Satya Nadella", feedURL: "https://api.xgo.ing/rss/user/baa68dbd9a9e461a96fd9b2e3f35dcbf", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-pmarca", name: "Marc Andreessen", feedURL: "https://api.xgo.ing/rss/user/63316630d94543f5a6480f230f483008", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-sundar", name: "Sundar Pichai", feedURL: "https://api.xgo.ing/rss/user/8324d65a63dc42c584a8c08cc8323c9f", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-rauchg", name: "Guillermo Rauch", feedURL: "https://api.xgo.ing/rss/user/e8750659b8154dbfa0489f451e044af1", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-martin-fowler", name: "Martin Fowler", feedURL: "https://api.xgo.ing/rss/user/55d2d3f3eaaf4357b3230e0b01a464d7", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-github", name: "GitHub", feedURL: "https://api.xgo.ing/rss/user/fa5b15f68a2e4df1ab301e26a4ab9190", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-figma", name: "Figma", feedURL: "https://api.xgo.ing/rss/user/f8a106a09a7d404fb8de7eb0c5ddd2a2", type: .twitter, category: .techLeader, language: .english),
        RSSSource(id: "tw-notion", name: "Notion", feedURL: "https://api.xgo.ing/rss/user/f97a26863aec4425b021720d4f8e4ede", type: .twitter, category: .techLeader, language: .english),
        
        // 投资人
        RSSSource(id: "tw-paulg", name: "Paul Graham", feedURL: "https://api.xgo.ing/rss/user/900549ddadf04e839d3f7a17ebaba3fc", type: .twitter, category: .vc, language: .english),
        RSSSource(id: "tw-naval", name: "Naval", feedURL: "https://api.xgo.ing/rss/user/b43bc203409e4c5a9c3ae86fe1ac00c9", type: .twitter, category: .vc, language: .english),
        RSSSource(id: "tw-a16z", name: "a16z", feedURL: "https://api.xgo.ing/rss/user/f3fedf817599470dbf8d8d11f0872475", type: .twitter, category: .vc, language: .english),
        RSSSource(id: "tw-yc", name: "Y Combinator", feedURL: "https://api.xgo.ing/rss/user/b1ab109f6afd42ab8ea32e17a19a3a3e", type: .twitter, category: .vc, language: .english),
        RSSSource(id: "tw-shl", name: "Sahil Lavingia", feedURL: "https://api.xgo.ing/rss/user/baad3713defe4182844d2756b4c2c9ed", type: .twitter, category: .vc, language: .english),
        RSSSource(id: "tw-andrew-chen", name: "andrew chen", feedURL: "https://api.xgo.ing/rss/user/a3eb6beb2d894da3a9b7ab6d2e46790e", type: .twitter, category: .vc, language: .english),
        
        // 中文 KOL
        RSSSource(id: "tw-baoyu", name: "宝玉", feedURL: "https://api.xgo.ing/rss/user/97f1484ae48c430fbbf3438099743674", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-lijigang", name: "李继刚", feedURL: "https://api.xgo.ing/rss/user/ca2fa444b6ea4b8b974fe148056e497a", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-guizang", name: "歸藏", feedURL: "https://api.xgo.ing/rss/user/831fac36aa0a49a9af79f35dc1c9b5d9", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-vista8", name: "向阳乔木", feedURL: "https://api.xgo.ing/rss/user/9de19c78f7454ad08c956c1a00d237fe", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-xiaohu", name: "小互", feedURL: "https://api.xgo.ing/rss/user/74e542992cf7441390c708f5601071d4", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-ai-huangshu", name: "AI产品黄叔", feedURL: "https://api.xgo.ing/rss/user/5b632b7fba274f62928cdcc9d3db4c5e", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-tw93", name: "Tw93", feedURL: "https://api.xgo.ing/rss/user/665fc88440fd4436acbc2e630d824926", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-viking", name: "Viking", feedURL: "https://api.xgo.ing/rss/user/aab44cb2665a49258cd81f63b0b55192", type: .twitter, category: .chineseKOL, language: .chinese),
        RSSSource(id: "tw-geek", name: "Geek", feedURL: "https://api.xgo.ing/rss/user/9cb3b60e689e4445a7fbdfd0be144126", type: .twitter, category: .chineseKOL, language: .chinese),
    ]
}
