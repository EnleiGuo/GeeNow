import Foundation

struct IfengSource: NewsSourceProtocol {
    let source = Source(
        id: "ifeng",
        name: "凤凰网",
        colorName: "red",
        title: "热点",
        type: .hottest,
        interval: 600,
        home: "https://www.ifeng.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.ifeng.com/") else {
            throw NetworkError.invalidURL
        }
        
        let html = try await NetworkService.shared.fetchHTML(url)
        
        // Parse var allData = {...}; from HTML
        guard let regex = try? NSRegularExpression(pattern: "var\\s+allData\\s*=\\s*(\\{[\\s\\S]*?\\});", options: []),
              let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
              let jsonRange = Range(match.range(at: 1), in: html) else {
            return []
        }
        
        let jsonStr = String(html[jsonRange])
        guard let jsonData = jsonStr.data(using: .utf8) else {
            return []
        }
        
        let response = try JSONDecoder().decode(IfengAllData.self, from: jsonData)
        
        return response.hotNews1.compactMap { item -> NewsItem? in
            guard !item.title.isEmpty else { return nil }
            
            return NewsItem(
                id: item.url,
                title: item.title,
                url: item.url,
                mobileUrl: item.url,
                sourceName: "凤凰网"
            )
        }
    }
}

private struct IfengAllData: Decodable {
    let hotNews1: [IfengNewsItem]
    
    struct IfengNewsItem: Decodable {
        let url: String
        let title: String
        let newsTime: String?
    }
}
