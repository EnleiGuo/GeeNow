import Foundation

struct Kr36Source: NewsSourceProtocol {
    let source = Source(
        id: "36kr",
        name: "36氪",
        colorName: "blue",
        title: "快讯",
        type: .realtime,
        interval: 600,
        home: "https://36kr.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.36kr.com/newsflashes") else {
            print("🔴 [36kr] Invalid URL")
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        
        print("🔵 [36kr] Fetching from: \(url)")
        
        let html: String
        do {
            html = try await NetworkService.shared.fetchHTML(url, headers: headers)
            print("🟢 [36kr] Got HTML, length: \(html.count)")
        } catch {
            print("🔴 [36kr] Fetch error: \(error)")
            throw error
        }
        
        let pattern = #"class="item-title"[^>]*href="(/newsflashes/\d+)"[^>]*>([^<]+)</a>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("🔴 [36kr] Regex compile failed")
            return []
        }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        print("🟢 [36kr] Regex matches: \(matches.count)")
        
        var seen = Set<String>()
        var results: [NewsItem] = []
        
        for match in matches {
            guard match.numberOfRanges >= 3 else { continue }
            
            let pathRange = match.range(at: 1)
            let titleRange = match.range(at: 2)
            
            let path = nsString.substring(with: pathRange)
            let title = nsString.substring(with: titleRange).trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !title.isEmpty, !seen.contains(path) else { continue }
            seen.insert(path)
            
            let fullUrl = "https://www.36kr.com\(path)"
            
            results.append(NewsItem(
                id: path,
                title: title,
                url: fullUrl,
                mobileUrl: fullUrl,
                sourceName: "36氪快讯"
            ))
        }
        
        print("🟢 [36kr] Parsed \(results.count) items")
        return results
    }
}
