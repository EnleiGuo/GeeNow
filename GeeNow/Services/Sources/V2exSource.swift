import Foundation

struct V2exSource: NewsSourceProtocol {
    let source = Source(
        id: "v2ex",
        name: "V2EX",
        colorName: "slate",
        title: "热门",
        type: .hottest,
        home: "https://v2ex.com/",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.v2ex.com/api/topics/hot.json") else {
            throw NetworkError.invalidURL
        }
        
        let response: [V2exItem] = try await NetworkService.shared.fetch(url)
        
        return response.map { item in
            NewsItem(
                id: "\(item.id)",
                title: item.title,
                url: item.url,
                extra: .init(
                    hover: nil,
                    info: "\(item.replies)回复"
                ),
                content: item.content.isEmpty ? nil : item.content,
                sourceName: "V2EX"
            )
        }
    }
}

private struct V2exItem: Decodable {
    let id: Int
    let title: String
    let url: String
    let content: String
    let replies: Int
}
