import Foundation

struct CNBetaSource: NewsSourceProtocol {
    let source = Source(
        id: "cnbeta",
        name: "cnBeta",
        colorName: "blue",
        type: .realtime,
        home: "https://www.cnbeta.com.tw",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://rss.cnbeta.com.tw/") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        // 使用自定义 session 来跳过 SSL 验证（cnBeta 的 SSL 证书有问题）
        let session = URLSession(configuration: .default, delegate: SSLBypassDelegate(), delegateQueue: nil)
        let (data, _) = try await session.data(for: request)
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingFailed(NSError(domain: "UTF8", code: -1))
        }
        
        return parseRSS(xmlString)
    }
    
    private func parseRSS(_ xml: String) -> [NewsItem] {
        var items: [NewsItem] = []
        
        // 简单的 XML 解析，提取 <item> 标签
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
            
            guard !title.isEmpty, !link.isEmpty else { continue }
            
            // 解析日期
            let pubDate = parseRFC2822Date(pubDateStr)
            
            let cleanDescription = cleanHTML(description)
            let category = extractCategory(from: link)
            let authorName = extractTag(from: itemContent, tag: "author")
            
            let item = NewsItem(
                id: guid.isEmpty ? link : guid,
                title: cleanHTML(title),
                url: link,
                mobileUrl: link,
                pubDate: pubDate,
                extra: .init(
                    info: category.isEmpty ? formatTimeAgo(pubDate) : "\(category) · \(formatTimeAgo(pubDate))"
                ),
                content: cleanDescription,
                author: authorName.isEmpty ? nil : authorName,
                sourceName: "cnBeta"
            )
            items.append(item)
        }
        
        return items
    }
    
    private func extractTag(from content: String, tag: String) -> String {
        // 处理 CDATA
        let cdataPattern = "<\(tag)>\\s*<!\\[CDATA\\[(.*?)\\]\\]>\\s*</\(tag)>"
        if let cdataRegex = try? NSRegularExpression(pattern: cdataPattern, options: .dotMatchesLineSeparators),
           let match = cdataRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        
        // 普通标签
        let pattern = "<\(tag)>(.*?)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
              let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else {
            return ""
        }
        return String(content[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cleanHTML(_ html: String) -> String {
        var result = html
        // 移除 CDATA
        result = result.replacingOccurrences(of: "<!\\[CDATA\\[", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\]\\]>", with: "", options: .regularExpression)
        // 移除 HTML 标签
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // 清理多余空白
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractCategory(from link: String) -> String {
        let pattern = "/articles/(\\w+)/"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: link, options: [], range: NSRange(link.startIndex..., in: link)),
              let range = Range(match.range(at: 1), in: link) else {
            return ""
        }
        
        let category = String(link[range])
        let categoryMap: [String: String] = [
            "tech": "科技",
            "game": "游戏",
            "science": "科学",
            "movie": "影视",
            "music": "音乐",
            "comic": "动漫"
        ]
        return categoryMap[category] ?? ""
    }
    
    private func parseRFC2822Date(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateStr)
    }
    
    private func formatTimeAgo(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60))分钟前"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))小时前"
        } else {
            return "\(Int(interval / 86400))天前"
        }
    }
}

// SSL 验证绕过代理（cnBeta 的 SSL 证书有问题）
private final class SSLBypassDelegate: NSObject, URLSessionDelegate, Sendable {
    nonisolated func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
