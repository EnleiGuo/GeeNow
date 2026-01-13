import Foundation

struct SspaiSource: NewsSourceProtocol {
    let source = Source(
        id: "sspai",
        name: "少数派",
        colorName: "red",
        type: .hottest,
        interval: 600,
        home: "https://sspai.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        guard let url = URL(string: "https://sspai.com/api/v1/article/tag/page/get?limit=30&offset=0&created_at=\(timestamp)&tag=%E7%83%AD%E9%97%A8%E6%96%87%E7%AB%A0&released=false") else {
            throw NetworkError.invalidURL
        }
        
        let response: SspaiResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.enumerated().map { index, item in
            NewsItem(
                id: "\(item.id)",
                title: item.title,
                url: "https://sspai.com/post/\(item.id)",
                mobileUrl: "https://sspai.com/post/\(item.id)",
                sourceName: "少数派"
            )
        }
    }
}

private struct SspaiResponse: Decodable {
    let data: [SspaiItem]
    
    struct SspaiItem: Decodable {
        let id: Int
        let title: String
    }
}
