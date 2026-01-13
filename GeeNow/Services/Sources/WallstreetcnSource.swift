import Foundation

struct WallstreetcnSource: NewsSourceProtocol {
    let source = Source(
        id: "wallstreetcn",
        name: "华尔街见闻",
        colorName: "blue",
        title: "快讯",
        type: .realtime,
        interval: 300,
        home: "https://wallstreetcn.com",
        column: .finance
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://api-one.wallstcn.com/apiv1/content/lives?channel=global-channel&limit=30") else {
            throw NetworkError.invalidURL
        }
        
        let response: WallstreetcnResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.items.compactMap { item -> NewsItem? in
            let title = item.title ?? item.content_text
            guard !title.isEmpty else { return nil }
            
            return NewsItem(
                id: "\(item.id)",
                title: title,
                url: item.uri,
                mobileUrl: item.uri,
                content: item.content_text,
                sourceName: "华尔街见闻"
            )
        }
    }
}

private struct WallstreetcnResponse: Decodable {
    let data: WallstreetcnData
    
    struct WallstreetcnData: Decodable {
        let items: [WallstreetcnItem]
    }
    
    struct WallstreetcnItem: Decodable {
        let id: Int
        let uri: String
        let title: String?
        let content_text: String
    }
}
