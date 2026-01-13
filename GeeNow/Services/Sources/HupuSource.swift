import Foundation

struct HupuSource: NewsSourceProtocol {
    let source = Source(
        id: "hupu",
        name: "虎扑",
        colorName: "red",
        title: "热帖",
        type: .hottest,
        interval: 600,
        home: "https://hupu.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://bbs.hupu.com/topic-daily-hot") else {
            print("🔴 [Hupu] Invalid URL")
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        
        print("🔵 [Hupu] Fetching from: \(url)")
        
        let html: String
        do {
            html = try await NetworkService.shared.fetchHTML(url, headers: headers)
            print("🟢 [Hupu] Got HTML, length: \(html.count)")
        } catch {
            print("🔴 [Hupu] Fetch error: \(error)")
            throw error
        }
        
        let pattern = #"<li class="bbs-sl-web-post-body">[\s\S]*?<a href="(/[^"]+?\.html)"[^>]*?class="p-title"[^>]*>([^<]+)</a>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("🔴 [Hupu] Regex compile failed")
            return []
        }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        print("🟢 [Hupu] Regex matches: \(matches.count)")
        
        let items = matches.compactMap { match -> NewsItem? in
            guard match.numberOfRanges >= 3 else { return nil }
            
            let pathRange = match.range(at: 1)
            let titleRange = match.range(at: 2)
            
            let path = nsString.substring(with: pathRange)
            let title = nsString.substring(with: titleRange).trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !title.isEmpty else { return nil }
            
            let fullUrl = "https://bbs.hupu.com\(path)"
            
            return NewsItem(
                id: path,
                title: title,
                url: fullUrl,
                mobileUrl: fullUrl,
                sourceName: "虎扑热帖"
            )
        }
        print("🟢 [Hupu] Parsed \(items.count) items")
        return items
    }
}
