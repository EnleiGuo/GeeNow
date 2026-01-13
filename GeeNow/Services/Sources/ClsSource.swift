import Foundation

struct ClsSource: NewsSourceProtocol {
    let source = Source(
        id: "cls",
        name: "财联社",
        colorName: "red",
        title: "电报",
        type: .realtime,
        interval: 300,
        home: "https://www.cls.cn",
        column: .finance
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.cls.cn/nodeapi/updateTelegraphList?app=CailianpressWeb&os=web&sv=7.7.5") else {
            print("🔴 [CLS] Invalid URL")
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "application/json, text/plain, */*",
            "Referer": "https://www.cls.cn/telegraph",
            "Origin": "https://www.cls.cn"
        ]
        
        print("🔵 [CLS] Fetching from: \(url)")
        
        do {
            // 先获取原始数据查看内容
            let rawHtml = try await NetworkService.shared.fetchHTML(url, headers: headers)
            print("🟡 [CLS] Raw response first 500 chars: \(String(rawHtml.prefix(500)))")
            
            let response: ClsTelegraphResponse = try await NetworkService.shared.fetch(url, headers: headers)
            print("🟢 [CLS] Got response, roll_data count: \(response.data.roll_data.count)")
            
            let items = response.data.roll_data.filter { $0.is_ad != 1 }.compactMap { item -> NewsItem? in
                let title = (item.title?.isEmpty == false ? item.title : item.brief) ?? item.brief
                guard !title.isEmpty else { return nil }
                
                return NewsItem(
                    id: "\(item.id)",
                    title: title,
                    url: "https://www.cls.cn/detail/\(item.id)",
                    mobileUrl: item.shareurl,
                    content: item.brief,
                    sourceName: "财联社"
                )
            }
            print("🟢 [CLS] Parsed \(items.count) items")
            return items
        } catch {
            print("🔴 [CLS] Error: \(error)")
            throw error
        }
    }
}

private struct ClsTelegraphResponse: Decodable {
    let data: ClsData
    
    struct ClsData: Decodable {
        let roll_data: [ClsItem]
    }
    
    struct ClsItem: Decodable {
        let id: Int
        let title: String?
        let brief: String
        let shareurl: String
        let is_ad: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, title, brief, shareurl, is_ad
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = (try? container.decode(Int.self, forKey: .id)) ?? 0
            title = try? container.decode(String.self, forKey: .title)
            brief = (try? container.decode(String.self, forKey: .brief)) ?? ""
            shareurl = (try? container.decode(String.self, forKey: .shareurl)) ?? ""
            is_ad = try? container.decode(Int.self, forKey: .is_ad)
        }
    }
}
