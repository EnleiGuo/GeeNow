import Foundation

actor RSSFeedService {
    static let shared = RSSFeedService()
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    func fetchItems(from source: RSSSource) async throws -> [SubscriptionItem] {
        guard let url = URL(string: source.feedURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingFailed(NSError(domain: "UTF8", code: -1))
        }
        
        return parseRSS(xmlString, source: source)
    }
    
    func fetchItemsFromMultipleSources(_ sources: [RSSSource]) async -> [SubscriptionItem] {
        await withTaskGroup(of: [SubscriptionItem].self) { group in
            for source in sources {
                group.addTask {
                    do {
                        return try await self.fetchItems(from: source)
                    } catch {
                        print("Failed to fetch from \(source.name): \(error)")
                        return []
                    }
                }
            }
            
            var allItems: [SubscriptionItem] = []
            for await items in group {
                allItems.append(contentsOf: items)
            }
            
            return allItems.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        }
    }
    
    private func parseRSS(_ xml: String, source: RSSSource) -> [SubscriptionItem] {
        let isAtomFeed = xml.contains("<feed") && xml.contains("<entry>")
        
        if isAtomFeed {
            return parseAtomFeed(xml, source: source)
        } else {
            return parseRSSFeed(xml, source: source)
        }
    }
    
    private func parseAtomFeed(_ xml: String, source: RSSSource) -> [SubscriptionItem] {
        var items: [SubscriptionItem] = []
        
        let entryPattern = "<entry>(.*?)</entry>"
        guard let entryRegex = try? NSRegularExpression(pattern: entryPattern, options: .dotMatchesLineSeparators) else {
            return items
        }
        
        let range = NSRange(xml.startIndex..., in: xml)
        let matches = entryRegex.matches(in: xml, options: [], range: range)
        
        for match in matches {
            guard let entryRange = Range(match.range(at: 1), in: xml) else { continue }
            let entryContent = String(xml[entryRange])
            
            let title = extractTag(from: entryContent, tag: "title")
            let link = extractAtomLink(from: entryContent)
            let pubDateStr = extractTag(from: entryContent, tag: "published")
            let updatedStr = extractTag(from: entryContent, tag: "updated")
            let id = extractTag(from: entryContent, tag: "yt:videoId")
            let description = extractTag(from: entryContent, tag: "media:description")
            
            guard !title.isEmpty else { continue }
            
            let pubDate = parseDate(pubDateStr.isEmpty ? updatedStr : pubDateStr)
            let cleanTitle = cleanHTML(title)
            let cleanDescription = cleanHTML(description)
            let itemId = id.isEmpty ? link : id
            
            switch source.type {
            case .video:
                let videoId = id.isEmpty ? extractYouTubeVideoId(from: link) : id
                let thumbnailURL = videoId.map { "https://img.youtube.com/vi/\($0)/maxresdefault.jpg" }
                let viewCount = extractAtomViewCount(from: entryContent)
                let item = VideoItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    videoURL: link,
                    thumbnailURL: thumbnailURL,
                    duration: nil,
                    viewCount: viewCount,
                    channelName: source.name,
                    description: cleanDescription
                )
                items.append(.video(item))
                
            default:
                let item = ArticleItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    summary: String(cleanDescription.prefix(200)),
                    content: cleanDescription,
                    imageURL: nil,
                    author: nil,
                    score: nil
                )
                items.append(.article(item))
            }
        }
        
        return items
    }
    
    private func parseRSSFeed(_ xml: String, source: RSSSource) -> [SubscriptionItem] {
        var items: [SubscriptionItem] = []
        
        let itemPattern = "<item>(.*?)</item>"
        guard let itemRegex = try? NSRegularExpression(pattern: itemPattern, options: .dotMatchesLineSeparators) else {
            return items
        }
        
        let range = NSRange(xml.startIndex..., in: xml)
        let matches = itemRegex.matches(in: xml, options: [], range: range)
        
        for match in matches {
            guard let itemRange = Range(match.range(at: 1), in: xml) else { continue }
            let itemContent = String(xml[itemRange])
            
            let title = extractTag(from: itemContent, tag: "title")
            let link = extractTag(from: itemContent, tag: "link")
            let pubDateStr = extractTag(from: itemContent, tag: "pubDate")
            let guid = extractTag(from: itemContent, tag: "guid")
            let description = extractTag(from: itemContent, tag: "description")
            
            guard !title.isEmpty else { continue }
            
            let pubDate = parseDate(pubDateStr)
            let cleanTitle = cleanHTML(title)
            let cleanDescription = cleanHTML(description)
            let itemId = guid.isEmpty ? (link.isEmpty ? UUID().uuidString : link) : guid
            
            switch source.type {
            case .article:
                let imageURL = extractImageURL(from: itemContent) ?? extractImageURL(from: description)
                let author = extractTag(from: itemContent, tag: "dc:creator")
                let item = ArticleItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    summary: String(cleanDescription.prefix(200)),
                    content: cleanDescription,
                    imageURL: imageURL,
                    author: author.isEmpty ? nil : cleanHTML(author),
                    score: nil
                )
                items.append(.article(item))
                
            case .podcast:
                let audioURL = extractEnclosureURL(from: itemContent)
                let duration = extractDuration(from: itemContent)
                let coverURL = extractImageURL(from: itemContent) ?? extractItunesImage(from: xml)
                let item = PodcastItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    audioURL: audioURL,
                    duration: duration,
                    episodeNumber: extractEpisodeNumber(from: itemContent),
                    coverImageURL: coverURL,
                    description: cleanDescription
                )
                items.append(.podcast(item))
                
            case .video:
                let videoId = extractYouTubeVideoId(from: link)
                let thumbnailURL = videoId.map { "https://img.youtube.com/vi/\($0)/maxresdefault.jpg" }
                let item = VideoItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    videoURL: link,
                    thumbnailURL: thumbnailURL ?? extractImageURL(from: itemContent),
                    duration: nil,
                    viewCount: extractViewCount(from: itemContent),
                    channelName: source.name,
                    description: cleanDescription
                )
                items.append(.video(item))
                
            case .twitter:
                let content = description.isEmpty ? title : description
                let mediaURLs = extractMediaURLs(from: itemContent)
                let item = TweetItem(
                    id: itemId,
                    title: cleanTitle,
                    sourceId: source.id,
                    sourceName: source.name,
                    pubDate: pubDate,
                    link: link,
                    content: cleanHTML(content),
                    authorName: source.name,
                    authorHandle: extractTwitterHandle(from: source.name),
                    authorAvatarURL: nil,
                    mediaURLs: mediaURLs.isEmpty ? nil : mediaURLs,
                    likeCount: nil,
                    retweetCount: nil,
                    replyCount: nil
                )
                items.append(.tweet(item))
            }
        }
        
        return items
    }
    
    private func extractAtomLink(from content: String) -> String {
        let pattern = "<link[^>]+href=[\"']([^\"']+)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        return ""
    }
    
    private func extractAtomViewCount(from content: String) -> Int? {
        let pattern = "<media:statistics[^>]+views=[\"']([^\"']+)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return Int(String(content[range]))
        }
        return nil
    }
    
    // MARK: - Tag Extraction
    
    private func extractTag(from content: String, tag: String) -> String {
        let cdataPattern = "<\(tag)[^>]*>\\s*<!\\[CDATA\\[(.*?)\\]\\]>\\s*</\(tag)>"
        if let cdataRegex = try? NSRegularExpression(pattern: cdataPattern, options: .dotMatchesLineSeparators),
           let match = cdataRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        
        let pattern = "<\(tag)[^>]*>(.*?)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
              let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else {
            return ""
        }
        return String(content[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractEnclosureURL(from content: String) -> String? {
        let pattern = "<enclosure[^>]+url=[\"']([^\"']+)[\"']"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else {
            return nil
        }
        let url = String(content[range])
        return url.isEmpty ? nil : url
    }
    
    private func extractImageURL(from content: String) -> String? {
        let patterns = [
            "<media:thumbnail[^>]+url=[\"']([^\"']+)[\"']",
            "<media:content[^>]+url=[\"']([^\"']+)[\"'][^>]+type=[\"']image",
            "<enclosure[^>]+url=[\"']([^\"']+\\.(jpg|jpeg|png|gif|webp))[\"']",
            "<img[^>]+src=[\"']([^\"']+)[\"']",
            "src=[\"']([^\"']+\\.(jpg|jpeg|png|gif|webp))[\"']"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
               let range = Range(match.range(at: 1), in: content) {
                let url = String(content[range])
                if !url.isEmpty && (url.hasPrefix("http://") || url.hasPrefix("https://")) {
                    return url
                }
            }
        }
        return nil
    }
    
    private func extractItunesImage(from xml: String) -> String? {
        let pattern = "<itunes:image[^>]+href=[\"']([^\"']+)[\"']"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
              let range = Range(match.range(at: 1), in: xml) else {
            return nil
        }
        return String(xml[range])
    }
    
    private func extractDuration(from content: String) -> TimeInterval? {
        if let durationStr = extractTagContent(from: content, pattern: "<itunes:duration>([^<]+)</itunes:duration>") {
            return parseDuration(durationStr)
        }
        return nil
    }
    
    private func extractEpisodeNumber(from content: String) -> Int? {
        if let episodeStr = extractTagContent(from: content, pattern: "<itunes:episode>([^<]+)</itunes:episode>") {
            return Int(episodeStr)
        }
        return nil
    }
    
    private func extractYouTubeVideoId(from link: String) -> String? {
        let patterns = [
            "youtube\\.com/watch\\?v=([^&]+)",
            "youtu\\.be/([^?]+)",
            "youtube\\.com/embed/([^?]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: link, range: NSRange(link.startIndex..., in: link)),
               let range = Range(match.range(at: 1), in: link) {
                return String(link[range])
            }
        }
        return nil
    }
    
    private func extractViewCount(from content: String) -> Int? {
        if let viewStr = extractTagContent(from: content, pattern: "<media:statistics[^>]+views=[\"']([^\"']+)[\"']") {
            return Int(viewStr.replacingOccurrences(of: ",", with: ""))
        }
        return nil
    }
    
    private func extractMediaURLs(from content: String) -> [String] {
        var urls: [String] = []
        let pattern = "<media:content[^>]+url=[\"']([^\"']+)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range(at: 1), in: content) {
                    urls.append(String(content[range]))
                }
            }
        }
        return urls
    }
    
    private func extractTwitterHandle(from name: String) -> String {
        if let handleMatch = name.range(of: "@[A-Za-z0-9_]+", options: .regularExpression) {
            return String(name[handleMatch])
        }
        if let parenMatch = name.range(of: "\\(([^)]+)\\)", options: .regularExpression) {
            let handle = String(name[parenMatch]).dropFirst().dropLast()
            return "@\(handle)"
        }
        return "@\(name.replacingOccurrences(of: " ", with: ""))"
    }
    
    private func extractTagContent(from content: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else {
            return nil
        }
        return String(content[range])
    }
    
    // MARK: - Parsing Helpers
    
    private func parseDate(_ dateStr: String) -> Date? {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return f
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateStr) {
                return date
            }
        }
        
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso8601.date(from: dateStr)
    }
    
    private func parseDuration(_ durationStr: String) -> TimeInterval {
        let components = durationStr.split(separator: ":")
        switch components.count {
        case 1:
            return TimeInterval(components[0]) ?? 0
        case 2:
            let minutes = Int(components[0]) ?? 0
            let seconds = Int(components[1]) ?? 0
            return TimeInterval(minutes * 60 + seconds)
        case 3:
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            let seconds = Int(components[2]) ?? 0
            return TimeInterval(hours * 3600 + minutes * 60 + seconds)
        default:
            return 0
        }
    }
    
    private func cleanHTML(_ html: String) -> String {
        var result = html
        
        result = result.replacingOccurrences(of: "<![CDATA[", with: "")
        result = result.replacingOccurrences(of: "]]>", with: "")
        
        result = stripHTMLTags(result)
        
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&apos;", with: "'")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "&#x27;", with: "'")
        result = result.replacingOccurrences(of: "&#34;", with: "\"")
        result = result.replacingOccurrences(of: "&#x22;", with: "\"")
        result = result.replacingOccurrences(of: "&#38;", with: "&")
        result = result.replacingOccurrences(of: "&#x26;", with: "&")
        result = result.replacingOccurrences(of: "&hellip;", with: "...")
        result = result.replacingOccurrences(of: "&mdash;", with: "-")
        result = result.replacingOccurrences(of: "&ndash;", with: "-")
        result = result.replacingOccurrences(of: "&lsquo;", with: "'")
        result = result.replacingOccurrences(of: "&rsquo;", with: "'")
        result = result.replacingOccurrences(of: "&ldquo;", with: "\"")
        result = result.replacingOccurrences(of: "&rdquo;", with: "\"")
        
        result = decodeNumericHTMLEntities(result)
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func stripHTMLTags(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        
        var result = string
        if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: "")
        }
        return result
    }
    
    private func decodeNumericHTMLEntities(_ string: String) -> String {
        var result = string
        
        if let regex = try? NSRegularExpression(pattern: "&#(\\d+);", options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                if let codeRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[codeRange]),
                   let scalar = Unicode.Scalar(code) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }
        
        if let regex = try? NSRegularExpression(pattern: "&#x([0-9a-fA-F]+);", options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                if let codeRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[codeRange], radix: 16),
                   let scalar = Unicode.Scalar(code) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }
        
        return result
    }
}
