import Foundation

struct ZhihuSource: NewsSourceProtocol {
    let source = Source(
        id: "zhihu",
        name: "知乎",
        colorName: "blue",
        title: "热榜",
        type: .hottest,
        home: "https://www.zhihu.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.zhihu.com/api/v3/feed/topstory/hot-list-web?limit=30&desktop=true") else {
            throw NetworkError.invalidURL
        }
        
        let response: ZhihuResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.compactMap { item -> NewsItem? in
            let urlString = item.target.link.url
            let id = urlString.components(separatedBy: "/").last ?? UUID().uuidString
            
            return NewsItem(
                id: id,
                title: item.target.titleArea.text,
                url: urlString,
                extra: .init(
                    hover: item.target.excerptArea.text,
                    info: item.target.metricsArea.text
                ),
                content: item.target.excerptArea.text,
                sourceName: "知乎热榜"
            )
        }
    }
}

private struct ZhihuResponse: Decodable {
    let data: [ZhihuItem]
    
    struct ZhihuItem: Decodable {
        let target: Target
        
        struct Target: Decodable {
            let titleArea: TextArea
            let excerptArea: TextArea
            let metricsArea: TextArea
            let link: Link
            
            enum CodingKeys: String, CodingKey {
                case titleArea = "title_area"
                case excerptArea = "excerpt_area"
                case metricsArea = "metrics_area"
                case link
            }
        }
        
        struct TextArea: Decodable {
            let text: String
        }
        
        struct Link: Decodable {
            let url: String
        }
    }
}
