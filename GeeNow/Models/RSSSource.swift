import Foundation

struct RSSSource: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let feedURL: String
    let type: RSSSourceType
    let category: RSSSourceCategory
    let language: RSSSourceLanguage
    let icon: String?
    
    init(
        id: String,
        name: String,
        feedURL: String,
        type: RSSSourceType,
        category: RSSSourceCategory,
        language: RSSSourceLanguage = .chinese,
        icon: String? = nil
    ) {
        self.id = id
        self.name = name
        self.feedURL = feedURL
        self.type = type
        self.category = category
        self.language = language
        self.icon = icon
    }
}

enum RSSSourceType: String, CaseIterable, Codable {
    case article = "文章"
    case podcast = "播客"
    case video = "视频"
    case twitter = "推文"
    
    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .podcast: return "mic.fill"
        case .video: return "play.rectangle.fill"
        case .twitter: return "bubble.left.fill"
        }
    }
    
    var color: String {
        switch self {
        case .article: return "blue"
        case .podcast: return "purple"
        case .video: return "red"
        case .twitter: return "cyan"
        }
    }
}

enum RSSSourceCategory: String, CaseIterable, Codable {
    case ai = "人工智能"
    case bigTech = "大厂技术"
    case tools = "开发工具"
    case media = "科技媒体"
    case personal = "个人博客"
    case frontend = "前端设计"
    case business = "商业创投"
    case openSource = "开源社区"
    case database = "数据库"
    case cloud = "云服务"
    
    case techPodcast = "科技播客"
    case businessPodcast = "商业播客"
    case lifePodcast = "生活播客"
    
    case aiVideo = "AI 视频"
    case techVideo = "技术教育"
    case interviewVideo = "访谈节目"
    case vcVideo = "VC/创投"
    
    case aiCompany = "AI 公司"
    case aiResearcher = "AI 研究者"
    case aiTool = "AI 工具"
    case techLeader = "科技领袖"
    case vc = "投资人"
    case chineseKOL = "中文 KOL"
    
    var icon: String {
        switch self {
        case .ai: return "cpu"
        case .bigTech: return "building.2"
        case .tools: return "wrench.and.screwdriver"
        case .media: return "newspaper"
        case .personal: return "person.crop.circle"
        case .frontend: return "paintbrush"
        case .business: return "chart.line.uptrend.xyaxis"
        case .openSource: return "chevron.left.forwardslash.chevron.right"
        case .database: return "cylinder"
        case .cloud: return "cloud"
        case .techPodcast: return "mic"
        case .businessPodcast: return "briefcase"
        case .lifePodcast: return "heart"
        case .aiVideo: return "sparkles.tv"
        case .techVideo: return "graduationcap"
        case .interviewVideo: return "person.2"
        case .vcVideo: return "dollarsign.circle"
        case .aiCompany: return "building"
        case .aiResearcher: return "brain"
        case .aiTool: return "hammer"
        case .techLeader: return "star"
        case .vc: return "banknote"
        case .chineseKOL: return "person.badge.clock"
        }
    }
}

enum RSSSourceLanguage: String, Codable {
    case chinese = "CN"
    case english = "EN"
    case bilingual = "双语"
    
    var displayName: String {
        rawValue
    }
}
