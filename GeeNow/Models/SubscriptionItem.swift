import Foundation

protocol SubscriptionItemProtocol: Identifiable, Hashable {
    var id: String { get }
    var title: String { get }
    var sourceId: String { get }
    var sourceName: String { get }
    var pubDate: Date? { get }
    var link: String { get }
    var itemType: RSSSourceType { get }
}

struct ArticleItem: SubscriptionItemProtocol {
    let id: String
    let title: String
    let sourceId: String
    let sourceName: String
    let pubDate: Date?
    let link: String
    let itemType: RSSSourceType = .article
    
    let summary: String?
    let content: String?
    let imageURL: String?
    let author: String?
    let score: Int?
    
    var displayDate: String {
        formatRelativeDate(pubDate)
    }
    
    var scoreText: String? {
        guard let score = score else { return nil }
        return "\(score)分"
    }
}

struct PodcastItem: SubscriptionItemProtocol {
    let id: String
    let title: String
    let sourceId: String
    let sourceName: String
    let pubDate: Date?
    let link: String
    let itemType: RSSSourceType = .podcast
    
    let audioURL: String?
    let duration: TimeInterval?
    let episodeNumber: Int?
    let coverImageURL: String?
    let description: String?
    
    var displayDate: String {
        formatRelativeDate(pubDate)
    }
    
    var durationText: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)小时\(mins)分钟"
        }
        return "\(minutes)分钟"
    }
    
    var episodeText: String? {
        guard let ep = episodeNumber else { return nil }
        return "EP\(ep)"
    }
}

struct VideoItem: SubscriptionItemProtocol {
    let id: String
    let title: String
    let sourceId: String
    let sourceName: String
    let pubDate: Date?
    let link: String
    let itemType: RSSSourceType = .video
    
    let videoURL: String?
    let thumbnailURL: String?
    let duration: TimeInterval?
    let viewCount: Int?
    let channelName: String?
    let description: String?
    
    var displayDate: String {
        formatRelativeDate(pubDate)
    }
    
    var durationText: String? {
        guard let duration = duration else { return nil }
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var viewCountText: String? {
        guard let count = viewCount else { return nil }
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

struct TweetItem: SubscriptionItemProtocol {
    let id: String
    let title: String
    let sourceId: String
    let sourceName: String
    let pubDate: Date?
    let link: String
    let itemType: RSSSourceType = .twitter
    
    let content: String
    let authorName: String
    let authorHandle: String
    let authorAvatarURL: String?
    let mediaURLs: [String]?
    let likeCount: Int?
    let retweetCount: Int?
    let replyCount: Int?
    
    var displayDate: String {
        formatRelativeDate(pubDate)
    }
    
    var likeText: String? {
        formatCount(likeCount)
    }
    
    var retweetText: String? {
        formatCount(retweetCount)
    }
    
    var replyText: String? {
        formatCount(replyCount)
    }
    
    private func formatCount(_ count: Int?) -> String? {
        guard let count = count else { return nil }
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

enum SubscriptionItem: Identifiable, Hashable {
    case article(ArticleItem)
    case podcast(PodcastItem)
    case video(VideoItem)
    case tweet(TweetItem)
    
    var id: String {
        switch self {
        case .article(let item): return item.id
        case .podcast(let item): return item.id
        case .video(let item): return item.id
        case .tweet(let item): return item.id
        }
    }
    
    var title: String {
        switch self {
        case .article(let item): return item.title
        case .podcast(let item): return item.title
        case .video(let item): return item.title
        case .tweet(let item): return item.title
        }
    }
    
    var sourceId: String {
        switch self {
        case .article(let item): return item.sourceId
        case .podcast(let item): return item.sourceId
        case .video(let item): return item.sourceId
        case .tweet(let item): return item.sourceId
        }
    }
    
    var sourceName: String {
        switch self {
        case .article(let item): return item.sourceName
        case .podcast(let item): return item.sourceName
        case .video(let item): return item.sourceName
        case .tweet(let item): return item.sourceName
        }
    }
    
    var pubDate: Date? {
        switch self {
        case .article(let item): return item.pubDate
        case .podcast(let item): return item.pubDate
        case .video(let item): return item.pubDate
        case .tweet(let item): return item.pubDate
        }
    }
    
    var itemType: RSSSourceType {
        switch self {
        case .article: return .article
        case .podcast: return .podcast
        case .video: return .video
        case .tweet: return .twitter
        }
    }
}

private func formatRelativeDate(_ date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
}
