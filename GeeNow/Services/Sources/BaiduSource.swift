import Foundation

struct BaiduSource: NewsSourceProtocol {
    let source = Source(
        id: "baidu",
        name: "百度热搜",
        colorName: "blue",
        type: .hottest,
        interval: 600,
        home: "https://www.baidu.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://top.baidu.com/board?tab=realtime") else {
            print("🔴 [Baidu] Invalid URL")
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        
        print("🔵 [Baidu] Fetching from: \(url)")
        
        let html: String
        do {
            html = try await NetworkService.shared.fetchHTML(url, headers: headers)
            print("🟢 [Baidu] Got HTML, length: \(html.count)")
        } catch {
            print("🔴 [Baidu] Fetch error: \(error)")
            throw error
        }
        
        guard let startRange = html.range(of: "<!--s-data:"),
              let endRange = html.range(of: "-->", range: startRange.upperBound..<html.endIndex) else {
            print("🔴 [Baidu] s-data markers not found in HTML")
            return []
        }
        
        let jsonStr = String(html[startRange.upperBound..<endRange.lowerBound])
        print("🟢 [Baidu] Extracted JSON length: \(jsonStr.count)")
        print("🟡 [Baidu] JSON first 500 chars: \(String(jsonStr.prefix(500)))")
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            print("🔴 [Baidu] Cannot convert JSON string to data")
            return []
        }
        
        do {
            let response = try JSONDecoder().decode(BaiduResponse.self, from: jsonData)
            print("🟢 [Baidu] Decoded response, cards count: \(response.data.cards.count)")
            
            guard let card = response.data.cards.first else {
                print("🔴 [Baidu] No cards found")
                return []
            }
            
            print("🟢 [Baidu] First card content count: \(card.content.count)")
            
            let items = card.content.enumerated().compactMap { index, item -> NewsItem? in
                if item.isTop == true { return nil }
                guard !item.word.isEmpty else { return nil }
                
                return NewsItem(
                    id: "\(item.word)_\(index)",
                    title: item.word,
                    url: item.rawUrl,
                    mobileUrl: item.rawUrl,
                    extra: .init(hover: item.desc),
                    content: item.desc,
                    sourceName: "百度热搜"
                )
            }
            print("🟢 [Baidu] Parsed \(items.count) items")
            return items
        } catch {
            print("🔴 [Baidu] JSON decode error: \(error)")
            throw error
        }
    }
}

private struct BaiduResponse: Decodable {
    let data: BaiduData
    
    struct BaiduData: Decodable {
        let cards: [BaiduCard]
    }
    
    struct BaiduCard: Decodable {
        let content: [BaiduItem]
    }
    
    struct BaiduItem: Decodable {
        let isTop: Bool?
        let word: String
        let rawUrl: String
        let desc: String?
        
        enum CodingKeys: String, CodingKey {
            case isTop, word, rawUrl, desc
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            isTop = try? container.decode(Bool.self, forKey: .isTop)
            word = (try? container.decode(String.self, forKey: .word)) ?? ""
            rawUrl = (try? container.decode(String.self, forKey: .rawUrl)) ?? ""
            desc = try? container.decode(String.self, forKey: .desc)
        }
    }
}
