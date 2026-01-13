import Foundation

struct RSSArticle: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let link: String
    let pubDate: Date?
    let author: String?
    let category: String?
    let description: String?
    let content: String?
    let score: Int?
    let sourceName: String?
    let imageURL: String?
    
    var displayDate: String {
        guard let date = pubDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var scoreText: String? {
        guard let score = score else { return nil }
        return "\(score)分"
    }
}

struct RSSFeed: Codable {
    let items: [RSSArticle]
}

enum RSSCategory: String, CaseIterable {
    case all = "全部"
    case programming = "编程"
    case ai = "AI"
    case product = "产品"
    case business = "商业"
    
    var apiValue: String? {
        switch self {
        case .all: return nil
        case .programming: return "programming"
        case .ai: return "ai"
        case .product: return "product"
        case .business: return "business"
        }
    }
}
