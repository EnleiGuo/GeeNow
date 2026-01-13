import Foundation

struct BilibiliSource: NewsSourceProtocol {
    let source = Source(
        id: "bilibili",
        name: "哔哩哔哩",
        colorName: "blue",
        title: "热搜",
        type: .hottest,
        home: "https://www.bilibili.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://s.search.bilibili.com/main/hotword?limit=30") else {
            throw NetworkError.invalidURL
        }
        
        let response: BilibiliResponse = try await NetworkService.shared.fetch(url)
        
        return response.list.map { item in
            NewsItem(
                id: item.keyword,
                title: item.show_name,
                url: "https://search.bilibili.com/all?keyword=\(item.keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? item.keyword)",
                extra: .init(
                    hover: nil,
                    info: nil,
                    icon: item.icon.isEmpty ? nil : item.icon
                ),
                sourceName: "哔哩哔哩"
            )
        }
    }
}

private struct BilibiliResponse: Decodable {
    let list: [BilibiliItem]
    
    struct BilibiliItem: Decodable {
        let keyword: String
        let show_name: String
        let icon: String
    }
}
