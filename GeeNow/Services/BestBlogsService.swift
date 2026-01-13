import Foundation

actor BestBlogsService {
    static let shared = BestBlogsService()
    
    private let baseURL = "https://www.bestblogs.dev/zh/feeds/rss"
    private var memoryCache: [String: (articles: [RSSArticle], timestamp: Date)] = [:]
    private let cacheExpiration: TimeInterval = 900
    private let diskCache = ReadingDiskCache.shared
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    func fetchArticles(
        category: RSSCategory = .all,
        featured: Bool = false,
        minScore: Int? = nil,
        timeFilter: String = "1w",
        forceRefresh: Bool = false
    ) async throws -> [RSSArticle] {
        let cacheKey = "\(category.rawValue)-\(featured)-\(minScore ?? 0)-\(timeFilter)"
        
        if !forceRefresh {
            if let cached = memoryCache[cacheKey],
               Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
                return cached.articles
            }
            
            if let diskCached = diskCache.load(for: cacheKey),
               Date().timeIntervalSince(diskCached.timestamp) < cacheExpiration {
                memoryCache[cacheKey] = diskCached
                return diskCached.articles
            }
        }
        
        var urlComponents = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "timeFilter", value: timeFilter))
        queryItems.append(URLQueryItem(name: "type", value: "article"))
        
        if let apiValue = category.apiValue {
            queryItems.append(URLQueryItem(name: "category", value: apiValue))
        }
        
        if featured {
            queryItems.append(URLQueryItem(name: "featured", value: "y"))
        }
        
        if let minScore = minScore {
            queryItems.append(URLQueryItem(name: "minScore", value: String(minScore)))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingFailed(NSError(domain: "UTF8", code: -1))
        }
        
        let articles = parseRSS(xmlString)
        memoryCache[cacheKey] = (articles, Date())
        diskCache.save(articles: articles, for: cacheKey)
        
        return articles
    }
    
    func loadFromCache(
        category: RSSCategory = .all,
        featured: Bool = false,
        minScore: Int? = nil,
        timeFilter: String = "1w"
    ) -> [RSSArticle]? {
        let cacheKey = "\(category.rawValue)-\(featured)-\(minScore ?? 0)-\(timeFilter)"
        
        if let cached = memoryCache[cacheKey] {
            return cached.articles
        }
        
        if let diskCached = diskCache.load(for: cacheKey) {
            memoryCache[cacheKey] = diskCached
            return diskCached.articles
        }
        
        return nil
    }
    
    func clearCache() {
        memoryCache.removeAll()
        diskCache.clearAll()
    }
    
    private func parseRSS(_ xml: String) -> [RSSArticle] {
        var articles: [RSSArticle] = []
        
        let itemPattern = "<item>(.*?)</item>"
        guard let itemRegex = try? NSRegularExpression(pattern: itemPattern, options: .dotMatchesLineSeparators) else {
            return articles
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
            let author = extractTag(from: itemContent, tag: "dc:creator")
            let category = extractTag(from: itemContent, tag: "category")
            let imageURL = extractEnclosureURL(from: itemContent)
            
            guard !title.isEmpty, !link.isEmpty else { continue }
            
            let pubDate = parseRFC2822Date(pubDateStr)
            let fullContent = extractFullContent(from: description)
            let cleanFullContent = cleanHTML(fullContent)
            let extractedSummary = extractDetailedSummary(from: description)
            let cleanDescription = cleanHTML(extractedSummary)
            let truncatedDescription = truncateText(cleanDescription, maxLength: 200)
            let score = extractScore(from: title)
            let cleanTitle = removeScoreFromTitle(title)
            
            let article = RSSArticle(
                id: guid.isEmpty ? link : guid,
                title: cleanTitle,
                link: link,
                pubDate: pubDate,
                author: author.isEmpty ? nil : author,
                category: category.isEmpty ? nil : category,
                description: truncatedDescription.isEmpty ? nil : truncatedDescription,
                content: cleanFullContent.isEmpty ? nil : cleanFullContent,
                score: score,
                sourceName: "BestBlogs",
                imageURL: imageURL
            )
            articles.append(article)
        }
        
        return articles
    }
    
    private func extractDetailedSummary(from html: String) -> String {
        var decoded = html
        decoded = decoded.replacingOccurrences(of: "&lt;", with: "<")
        decoded = decoded.replacingOccurrences(of: "&gt;", with: ">")
        decoded = decoded.replacingOccurrences(of: "&quot;", with: "\"")
        decoded = decoded.replacingOccurrences(of: "&apos;", with: "'")
        decoded = decoded.replacingOccurrences(of: "&amp;", with: "&")
        
        if let detailedRange = decoded.range(of: "📝"),
           let pStart = decoded.range(of: "<p", range: detailedRange.upperBound..<decoded.endIndex),
           let pContentStart = decoded.range(of: ">", range: pStart.upperBound..<decoded.endIndex),
           let pEnd = decoded.range(of: "</p>", range: pContentStart.upperBound..<decoded.endIndex) {
            let content = String(decoded[pContentStart.upperBound..<pEnd.lowerBound])
            if !content.isEmpty {
                return content
            }
        }
        
        if let oneSentenceRange = decoded.range(of: "📌"),
           let pStart = decoded.range(of: "<p", range: oneSentenceRange.upperBound..<decoded.endIndex),
           let pContentStart = decoded.range(of: ">", range: pStart.upperBound..<decoded.endIndex),
           let pEnd = decoded.range(of: "</p>", range: pContentStart.upperBound..<decoded.endIndex) {
            let content = String(decoded[pContentStart.upperBound..<pEnd.lowerBound])
            if !content.isEmpty {
                return content
            }
        }
        
        return html
    }
    
    private func truncateText(_ text: String, maxLength: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= maxLength {
            return trimmed
        }
        let index = trimmed.index(trimmed.startIndex, offsetBy: maxLength)
        return String(trimmed[..<index]) + "..."
    }
    
    private func extractFullContent(from html: String) -> String {
        var decoded = html
        decoded = decoded.replacingOccurrences(of: "&lt;", with: "<")
        decoded = decoded.replacingOccurrences(of: "&gt;", with: ">")
        decoded = decoded.replacingOccurrences(of: "&quot;", with: "\"")
        decoded = decoded.replacingOccurrences(of: "&apos;", with: "'")
        decoded = decoded.replacingOccurrences(of: "&amp;", with: "&")
        
        var sections: [String] = []
        
        let sectionMarkers: [(emoji: String, title: String, endTag: String)] = [
            ("📝", "详细摘要", "</p>"),
            ("💡", "主要观点", "</ol>"),
            ("💬", "文章金句", "</ul>")
        ]
        
        for marker in sectionMarkers {
            if let emojiRange = decoded.range(of: marker.emoji) {
                var searchStart = emojiRange.upperBound
                
                if marker.endTag == "</p>" {
                    if let pStart = decoded.range(of: "<p", range: searchStart..<decoded.endIndex),
                       let pContentStart = decoded.range(of: ">", range: pStart.upperBound..<decoded.endIndex),
                       let pEnd = decoded.range(of: "</p>", range: pContentStart.upperBound..<decoded.endIndex) {
                        let content = String(decoded[pContentStart.upperBound..<pEnd.lowerBound])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        if !content.isEmpty {
                            sections.append("【\(marker.title)】\n\(content)")
                        }
                    }
                } else {
                    let listStartTag = marker.endTag == "</ol>" ? "<ol" : "<ul"
                    if let listStart = decoded.range(of: listStartTag, range: searchStart..<decoded.endIndex),
                       let listContentStart = decoded.range(of: ">", range: listStart.upperBound..<decoded.endIndex),
                       let listEnd = decoded.range(of: marker.endTag, range: listContentStart.upperBound..<decoded.endIndex) {
                        let listContent = String(decoded[listContentStart.upperBound..<listEnd.lowerBound])
                        let items = extractListItems(from: listContent)
                        if !items.isEmpty {
                            let formattedItems = items.enumerated().map { index, item in
                                marker.endTag == "</ol>" ? "\(index + 1). \(item)" : "• \(item)"
                            }.joined(separator: "\n")
                            sections.append("【\(marker.title)】\n\(formattedItems)")
                        }
                    }
                }
            }
        }
        
        if sections.isEmpty {
            return ""
        }
        
        return sections.joined(separator: "\n\n")
    }
    
    private func extractListItems(from html: String) -> [String] {
        var items: [String] = []
        var remaining = html
        
        while let liStart = remaining.range(of: "<li"),
              let liContentStart = remaining.range(of: ">", range: liStart.upperBound..<remaining.endIndex),
              let liEnd = remaining.range(of: "</li>", range: liContentStart.upperBound..<remaining.endIndex) {
            let itemContent = String(remaining[liContentStart.upperBound..<liEnd.lowerBound])
            let cleanItem = stripHTMLTags(itemContent).trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanItem.isEmpty {
                items.append(cleanItem)
            }
            remaining = String(remaining[liEnd.upperBound...])
        }
        
        return items
    }
    
    private func extractTag(from content: String, tag: String) -> String {
        let cdataPattern = "<\(tag)>\\s*<!\\[CDATA\\[(.*?)\\]\\]>\\s*</\(tag)>"
        if let cdataRegex = try? NSRegularExpression(pattern: cdataPattern, options: .dotMatchesLineSeparators),
           let match = cdataRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        
        let pattern = "<\(tag)>(.*?)</\(tag)>"
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
    
    private func cleanHTML(_ html: String) -> String {
        var result = html
        
        result = result.replacingOccurrences(of: "<!\\[CDATA\\[", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\]\\]>", with: "", options: .regularExpression)
        
        result = decodeHTMLEntities(result)
        result = stripHTMLTags(result)
        result = decodeHTMLEntities(result)
        
        result = result.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
        result = result.replacingOccurrences(of: " *\\n *", with: "\n", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\n{2,}", with: "\n\n", options: .regularExpression)
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func decodeHTMLEntities(_ string: String) -> String {
        var result = string
        
        let numericPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericPattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                if let codeRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[codeRange]),
                   let scalar = Unicode.Scalar(code) {
                    let charRange = Range(match.range, in: result)!
                    result.replaceSubrange(charRange, with: String(Character(scalar)))
                }
            }
        }
        
        let hexPattern = "&#x([0-9a-fA-F]+);"
        if let regex = try? NSRegularExpression(pattern: hexPattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                if let codeRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[codeRange], radix: 16),
                   let scalar = Unicode.Scalar(code) {
                    let charRange = Range(match.range, in: result)!
                    result.replaceSubrange(charRange, with: String(Character(scalar)))
                }
            }
        }
        
        let entities: [String: String] = [
            "&nbsp;": " ", "&ensp;": " ", "&emsp;": " ", "&thinsp;": " ",
            "&amp;": "&", "&lt;": "<", "&gt;": ">",
            "&quot;": "\"", "&apos;": "'",
            "&ldquo;": "\u{201C}", "&rdquo;": "\u{201D}", "&laquo;": "\u{00AB}", "&raquo;": "\u{00BB}",
            "&lsquo;": "\u{2018}", "&rsquo;": "\u{2019}", "&sbquo;": "\u{201A}", "&bdquo;": "\u{201E}",
            "&mdash;": "\u{2014}", "&ndash;": "\u{2013}", "&minus;": "\u{2212}",
            "&hellip;": "\u{2026}", "&bull;": "\u{2022}", "&middot;": "\u{00B7}",
            "&copy;": "\u{00A9}", "&reg;": "\u{00AE}", "&trade;": "\u{2122}",
            "&euro;": "\u{20AC}", "&pound;": "\u{00A3}", "&yen;": "\u{00A5}", "&cent;": "\u{00A2}",
            "&deg;": "\u{00B0}", "&plusmn;": "\u{00B1}", "&times;": "\u{00D7}", "&divide;": "\u{00F7}",
            "&frac12;": "\u{00BD}", "&frac14;": "\u{00BC}", "&frac34;": "\u{00BE}",
            "&rarr;": "\u{2192}", "&larr;": "\u{2190}", "&uarr;": "\u{2191}", "&darr;": "\u{2193}",
            "&hearts;": "\u{2665}", "&diams;": "\u{2666}", "&clubs;": "\u{2663}", "&spades;": "\u{2660}"
        ]
        
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement, options: .caseInsensitive)
        }
        
        return result
    }
    
    private func stripHTMLTags(_ html: String) -> String {
        var result = ""
        var inTag = false
        var inQuote: Character? = nil
        var tagBuffer = ""
        let blockEndTags = Set(["p", "div", "br", "li", "h1", "h2", "h3", "h4", "h5", "h6", "tr", "blockquote", "section", "article", "header", "footer"])
        
        for char in html {
            if inTag {
                tagBuffer.append(char)
                if inQuote != nil {
                    if char == inQuote {
                        inQuote = nil
                    }
                } else if char == "\"" || char == "'" {
                    inQuote = char
                } else if char == ">" {
                    inTag = false
                    let tag = tagBuffer.lowercased()
                    let isBlockEnd = blockEndTags.contains { tag.hasPrefix("/\($0)") || tag.hasPrefix("\($0)") && (tag.contains("/") || tag == "br" || tag == "br>") }
                    let isBr = tag.hasPrefix("br")
                    if (isBlockEnd || isBr) && !result.hasSuffix("\n") {
                        result.append("\n")
                    }
                    tagBuffer = ""
                }
            } else {
                if char == "<" {
                    inTag = true
                    tagBuffer = ""
                } else {
                    result.append(char)
                }
            }
        }
        
        return result
    }
    
    private func parseRFC2822Date(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateStr)
    }
    
    private func extractScore(from title: String) -> Int? {
        let pattern = "\\[(\\d+)分\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)),
              let range = Range(match.range(at: 1), in: title) else {
            return nil
        }
        return Int(title[range])
    }
    
    private func removeScoreFromTitle(_ title: String) -> String {
        let pattern = "\\[\\d+分\\]\\s*"
        return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}

class ReadingDiskCache {
    static let shared = ReadingDiskCache()
    private let defaults = UserDefaults.standard
    private let cachePrefix = "reading_cache_"
    
    private init() {}
    
    func save(articles: [RSSArticle], for key: String) {
        let encoded = articles.map { encodeArticle($0) }
        let data: [String: Any] = [
            "articles": encoded,
            "timestamp": Date().timeIntervalSince1970
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
            defaults.set(jsonData, forKey: cachePrefix + key)
        }
    }
    
    func load(for key: String) -> (articles: [RSSArticle], timestamp: Date)? {
        guard let jsonData = defaults.data(forKey: cachePrefix + key),
              let data = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let articlesData = data["articles"] as? [[String: Any]],
              let timestamp = data["timestamp"] as? TimeInterval else {
            return nil
        }
        let articles = articlesData.compactMap { decodeArticle($0) }
        return (articles, Date(timeIntervalSince1970: timestamp))
    }
    
    func clearAll() {
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(cachePrefix) }
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
    
    private func encodeArticle(_ article: RSSArticle) -> [String: Any] {
        var dict: [String: Any] = [
            "id": article.id,
            "title": article.title,
            "link": article.link
        ]
        if let pubDate = article.pubDate { dict["pubDate"] = pubDate.timeIntervalSince1970 }
        if let author = article.author { dict["author"] = author }
        if let category = article.category { dict["category"] = category }
        if let description = article.description { dict["description"] = description }
        if let content = article.content { dict["content"] = content }
        if let score = article.score { dict["score"] = score }
        if let sourceName = article.sourceName { dict["sourceName"] = sourceName }
        if let imageURL = article.imageURL { dict["imageURL"] = imageURL }
        return dict
    }
    
    private func decodeArticle(_ dict: [String: Any]) -> RSSArticle? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let link = dict["link"] as? String else {
            return nil
        }
        return RSSArticle(
            id: id,
            title: title,
            link: link,
            pubDate: (dict["pubDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) },
            author: dict["author"] as? String,
            category: dict["category"] as? String,
            description: dict["description"] as? String,
            content: dict["content"] as? String,
            score: dict["score"] as? Int,
            sourceName: dict["sourceName"] as? String,
            imageURL: dict["imageURL"] as? String
        )
    }
}
