import Foundation

struct ThepaperSource: NewsSourceProtocol {
    let source = Source(
        id: "thepaper",
        name: "澎湃新闻",
        colorName: "gray",
        title: "热榜",
        type: .hottest,
        interval: 1800,
        home: "https://www.thepaper.cn",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://cache.thepaper.cn/contentapi/wwwIndex/rightSidebar") else {
            throw NetworkError.invalidURL
        }
        
        let response: ThepaperResponse = try await NetworkService.shared.fetch(url)
        
        return response.data.hotNews.enumerated().map { index, item in
            NewsItem(
                id: item.contId,
                title: item.name,
                url: "https://www.thepaper.cn/newsDetail_forward_\(item.contId)",
                mobileUrl: "https://m.thepaper.cn/newsDetail_forward_\(item.contId)",
                sourceName: "澎湃新闻"
            )
        }
    }
}

private struct ThepaperResponse: Decodable {
    let data: ThepaperData
    
    struct ThepaperData: Decodable {
        let hotNews: [ThepaperItem]
    }
    
    struct ThepaperItem: Decodable {
        let contId: String
        let name: String
    }
}
