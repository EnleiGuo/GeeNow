import Foundation

struct JuejinSource: NewsSourceProtocol {
    let source = Source(
        id: "juejin",
        name: "稀土掘金",
        colorName: "blue",
        title: "热榜",
        type: .hottest,
        home: "https://juejin.cn",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://api.juejin.cn/content_api/v1/content/article_rank?category_id=1&type=hot&count=30&from=0") else {
            throw NetworkError.invalidURL
        }
        
        let response: JuejinResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.map { item in
            NewsItem(
                id: item.content.content_id,
                title: item.content.title,
                url: "https://juejin.cn/post/\(item.content.content_id)",
                extra: .init(
                    hover: nil,
                    info: "\(item.content_counter.view)阅读"
                ),
                sourceName: "稀土掘金"
            )
        }
    }
}

private struct JuejinResponse: Decodable {
    let data: [JuejinItem]
    
    struct JuejinItem: Decodable {
        let content: Content
        let content_counter: ContentCounter
        
        struct Content: Decodable {
            let content_id: String
            let title: String
        }
        
        struct ContentCounter: Decodable {
            let view: Int
        }
    }
}
