import Foundation

struct WeiboSource: NewsSourceProtocol {
    let source = Source(
        id: "weibo",
        name: "微博",
        colorName: "red",
        title: "热搜",
        type: .hottest,
        interval: 120,
        home: "https://weibo.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://weibo.com/ajax/side/hotSearch") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "Referer": "https://weibo.com/",
            "Accept": "application/json"
        ]
        
        let response: WeiboResponse = try await NetworkService.shared.fetch(url, headers: headers)
        
        return response.data.realtime.enumerated().compactMap { index, item -> NewsItem? in
            guard !item.word.isEmpty else { return nil }
            
            let searchURL = "https://s.weibo.com/weibo?q=%23\(item.word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? item.word)%23"
            
            var iconURL: String?
            if item.is_new == 1 {
                iconURL = "new"
            } else if item.is_hot == 1 {
                iconURL = "hot"
            } else if item.is_fei == 1 {
                iconURL = "boom"
            }
            
            return NewsItem(
                id: "\(item.word)_\(index)",
                title: item.word,
                url: searchURL,
                mobileUrl: searchURL,
                extra: .init(
                    hover: nil,
                    info: item.num > 0 ? formatNumber(item.num) : nil,
                    icon: iconURL
                ),
                sourceName: "微博热搜"
            )
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 100000000 {
            return String(format: "%.1f亿", Double(num) / 100000000)
        } else if num >= 10000 {
            return String(format: "%.1f万", Double(num) / 10000)
        }
        return "\(num)"
    }
}

private struct WeiboResponse: Decodable {
    let data: WeiboData
    
    struct WeiboData: Decodable {
        let realtime: [WeiboItem]
    }
    
    struct WeiboItem: Decodable {
        let word: String
        let num: Int
        let is_new: Int?
        let is_hot: Int?
        let is_fei: Int?
        
        enum CodingKeys: String, CodingKey {
            case word, num
            case is_new, is_hot, is_fei
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            word = try container.decode(String.self, forKey: .word)
            num = (try? container.decode(Int.self, forKey: .num)) ?? 0
            is_new = try? container.decode(Int.self, forKey: .is_new)
            is_hot = try? container.decode(Int.self, forKey: .is_hot)
            is_fei = try? container.decode(Int.self, forKey: .is_fei)
        }
    }
}
