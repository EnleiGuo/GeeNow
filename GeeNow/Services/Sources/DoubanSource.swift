import Foundation

struct DoubanSource: NewsSourceProtocol {
    let source = Source(
        id: "douban",
        name: "豆瓣",
        colorName: "green",
        title: "热门电影",
        type: .hottest,
        interval: 600,
        home: "https://www.douban.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://movie.douban.com/j/search_subjects?type=movie&tag=%E7%83%AD%E9%97%A8&page_limit=30&page_start=0") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "Referer": "https://movie.douban.com/",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)"
        ]
        
        let response: DoubanResponse = try await NetworkService.shared.fetch(url, headers: headers)
        
        return response.subjects.enumerated().map { index, item in
            NewsItem(
                id: item.id,
                title: item.title,
                url: item.url,
                mobileUrl: item.url,
                extra: .init(info: "⭐ \(item.rate)"),
                sourceName: "豆瓣电影"
            )
        }
    }
}

private struct DoubanResponse: Decodable {
    let subjects: [DoubanMovie]
    
    struct DoubanMovie: Decodable {
        let id: String
        let title: String
        let url: String
        let rate: String
    }
}
