import Foundation

struct ToutiaoSource: NewsSourceProtocol {
    let source = Source(
        id: "toutiao",
        name: "今日头条",
        colorName: "red",
        type: .hottest,
        home: "https://www.toutiao.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.toutiao.com/hot-event/hot-board/?origin=toutiao_pc") else {
            throw NetworkError.invalidURL
        }
        
        let response: ToutiaoResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.map { item in
            NewsItem(
                id: item.ClusterIdStr,
                title: item.Title,
                url: "https://www.toutiao.com/trending/\(item.ClusterIdStr)/",
                extra: .init(
                    hover: nil,
                    info: nil,
                    icon: item.LabelUri?.url
                ),
                sourceName: "今日头条"
            )
        }
    }
}

private struct ToutiaoResponse: Decodable {
    let data: [ToutiaoItem]
    
    struct ToutiaoItem: Decodable {
        let ClusterIdStr: String
        let Title: String
        let HotValue: String?
        let LabelUri: LabelUri?
        
        struct LabelUri: Decodable {
            let url: String
        }
    }
}
