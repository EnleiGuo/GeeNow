import Foundation

struct ITHomeSource: NewsSourceProtocol {
    let source = Source(
        id: "ithome",
        name: "IT之家",
        colorName: "red",
        type: .realtime,
        home: "https://www.ithome.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://api.ithome.com/json/newslist/news") else {
            throw NetworkError.invalidURL
        }
        
        let response: ITHomeResponse = try await NetworkService.shared.fetch(url)
        
        return response.newslist.map { item in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let pubDate = dateFormatter.date(from: item.postdate)
            
            return NewsItem(
                id: "\(item.newsid)",
                title: item.title,
                url: item.url,
                mobileUrl: item.url.replacingOccurrences(of: "www.ithome.com", with: "m.ithome.com"),
                pubDate: pubDate,
                extra: .init(
                    hover: item.description
                ),
                content: item.description,
                sourceName: "IT之家"
            )
        }
    }
}

private struct ITHomeResponse: Decodable {
    let newslist: [ITHomeItem]
    
    struct ITHomeItem: Decodable {
        let newsid: Int
        let title: String
        let url: String
        let postdate: String
        let description: String
    }
}
