import Foundation

struct TiebaSource: NewsSourceProtocol {
    let source = Source(
        id: "tieba",
        name: "百度贴吧",
        colorName: "blue",
        title: "热议",
        type: .hottest,
        interval: 600,
        home: "https://tieba.baidu.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://tieba.baidu.com/hottopic/browse/topicList") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        
        print("🔵 [Tieba] Fetching...")
        
        do {
            let response: TiebaResponse = try await NetworkService.shared.fetch(url, headers: headers)
            let topicList = response.data.bang_topic.topic_list
            
            print("🟢 [Tieba] Got \(topicList.count) topics")
            
            for (index, item) in topicList.prefix(5).enumerated() {
                print("🔍 [Tieba] Item \(index): id='\(item.topic_id)', name='\(item.topic_name.prefix(20))'")
            }
            
            let items = topicList.map { item in
                NewsItem(
                    id: item.topic_id,
                    title: item.topic_name,
                    url: item.topic_url,
                    mobileUrl: item.topic_url,
                    sourceName: "百度贴吧"
                )
            }
            
            print("🟢 [Tieba] Returning \(items.count) items")
            return items
        } catch {
            print("🔴 [Tieba] Error: \(error)")
            throw error
        }
    }
}

private struct TiebaResponse: Decodable {
    let data: TiebaData
    
    struct TiebaData: Decodable {
        let bang_topic: BangTopic
    }
    
    struct BangTopic: Decodable {
        let topic_list: [TiebaItem]
    }
    
    struct TiebaItem: Decodable {
        let topic_id: String
        let topic_name: String
        let topic_url: String
        
        enum CodingKeys: String, CodingKey {
            case topic_id, topic_name, topic_url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let intId = try? container.decode(Int.self, forKey: .topic_id) {
                topic_id = String(intId)
            } else {
                topic_id = (try? container.decode(String.self, forKey: .topic_id)) ?? UUID().uuidString
            }
            
            topic_name = (try? container.decode(String.self, forKey: .topic_name)) ?? ""
            topic_url = (try? container.decode(String.self, forKey: .topic_url)) ?? ""
        }
    }
}
