import Foundation

struct GithubSource: NewsSourceProtocol {
    let source = Source(
        id: "github",
        name: "Github",
        colorName: "gray",
        title: "Trending",
        type: .hottest,
        interval: 600,
        home: "https://github.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://api.github.com/search/repositories?q=created:>\(dateString())&sort=stars&order=desc&per_page=30") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "GeeNow-iOS"
        ]
        
        let response: GithubResponse = try await NetworkService.shared.fetch(url, headers: headers)
        
        return response.items.enumerated().map { index, item in
            NewsItem(
                id: "\(item.id)",
                title: item.full_name + (item.description.map { " - \($0)" } ?? ""),
                url: item.html_url,
                mobileUrl: item.html_url,
                extra: .init(info: "⭐ \(item.stargazers_count)"),
                content: item.description,
                sourceName: "Github Trending"
            )
        }
    }
    
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date().addingTimeInterval(-86400 * 7))
    }
}

private struct GithubResponse: Decodable {
    let items: [GithubRepo]
    
    struct GithubRepo: Decodable {
        let id: Int
        let full_name: String
        let html_url: String
        let description: String?
        let stargazers_count: Int
    }
}
