import Foundation

struct Jin10Source: NewsSourceProtocol {
    let source = Source(
        id: "jin10",
        name: "金十数据",
        colorName: "blue",
        type: .realtime,
        interval: 600,
        home: "https://www.jin10.com",
        column: .finance
    )
    
    func fetch() async throws -> [NewsItem] {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        guard let url = URL(string: "https://www.jin10.com/flash_newest.js?t=\(timestamp)") else {
            throw NetworkError.invalidURL
        }
        
        print("🔵 [Jin10] Fetching from: \(url)")
        
        let rawData = try await NetworkService.shared.fetchHTML(url, headers: [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ])
        
        print("🟢 [Jin10] Raw data length: \(rawData.count)")
        print("🟡 [Jin10] Raw first 200: \(String(rawData.prefix(200)))")
        
        var jsonStr = rawData.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if jsonStr.hasPrefix("var newest = ") {
            jsonStr = String(jsonStr.dropFirst("var newest = ".count))
        }
        if jsonStr.hasPrefix("var newest=") {
            jsonStr = String(jsonStr.dropFirst("var newest=".count))
        }
        
        while jsonStr.hasSuffix(";") {
            jsonStr = String(jsonStr.dropLast())
        }
        
        jsonStr = jsonStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            print("🔴 [Jin10] Cannot convert to data")
            throw NetworkError.invalidResponse
        }
        
        let items: [Jin10Item]
        do {
            items = try JSONDecoder().decode([Jin10Item].self, from: jsonData)
            print("🟢 [Jin10] Decoded \(items.count) items")
        } catch {
            print("🔴 [Jin10] Decode error: \(error)")
            throw error
        }
        
        for (index, item) in items.prefix(5).enumerated() {
            print("🔍 [Jin10] Item \(index): title='\(item.data.title ?? "nil")', content='\(String((item.data.content ?? "nil").prefix(30)))', channel=\(item.channel ?? [])")
        }
        
        let result = items.prefix(30).compactMap { item -> NewsItem? in
            let hasContent = (item.data.title != nil && !item.data.title!.isEmpty) || 
                            (item.data.content != nil && !item.data.content!.isEmpty)
            let hasChannel5 = item.channel?.contains(5) ?? false
            
            guard hasContent, !hasChannel5 else {
                return nil
            }
            
            let content = (item.data.title?.isEmpty == false ? item.data.title : item.data.content) ?? ""
            
            let text = content.replacingOccurrences(of: "</?b>", with: "", options: .regularExpression)
            
            var title = text
            var desc: String?
            
            if let regex = try? NSRegularExpression(pattern: "^【([^】]+)】(.*)$", options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let titleRange = Range(match.range(at: 1), in: text) {
                    title = String(text[titleRange])
                }
                if let descRange = Range(match.range(at: 2), in: text) {
                    let descText = String(text[descRange]).trimmingCharacters(in: .whitespaces)
                    if !descText.isEmpty {
                        desc = descText
                    }
                }
            }
            
            return NewsItem(
                id: item.id,
                title: title,
                url: "https://flash.jin10.com/detail/\(item.id)",
                mobileUrl: "https://flash.jin10.com/detail/\(item.id)",
                extra: .init(
                    hover: desc,
                    info: item.important == 1 ? "⭐" : nil
                ),
                content: desc,
                sourceName: "金十数据"
            )
        }
        
        print("🟢 [Jin10] Final result: \(result.count) items")
        return result
    }
}

private struct Jin10Item: Decodable {
    let id: String
    let time: String
    let data: Jin10Data
    let important: Int?
    let channel: [Int]?
    
    struct Jin10Data: Decodable {
        let title: String?
        let content: String?
    }
}
