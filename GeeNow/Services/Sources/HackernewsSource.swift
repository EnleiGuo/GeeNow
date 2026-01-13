import Foundation

struct HackernewsSource: NewsSourceProtocol {
    let source = Source(
        id: "hackernews",
        name: "Hacker News",
        colorName: "orange",
        type: .hottest,
        interval: 600,
        home: "https://news.ycombinator.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        // 获取 top stories IDs
        guard let topStoriesURL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
            throw NetworkError.invalidURL
        }
        
        let storyIds: [Int] = try await NetworkService.shared.fetch(topStoriesURL)
        let limitedIds = Array(storyIds.prefix(30))
        
        // 并发获取 story 详情
        return try await withThrowingTaskGroup(of: NewsItem?.self) { group in
            for id in limitedIds {
                group.addTask {
                    guard let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
                        return nil
                    }
                    
                    let story: HackerNewsStory = try await NetworkService.shared.fetch(storyURL)
                    
                    return NewsItem(
                        id: "\(story.id)",
                        title: story.title,
                        url: "https://news.ycombinator.com/item?id=\(story.id)",
                        mobileUrl: "https://news.ycombinator.com/item?id=\(story.id)",
                        extra: .init(info: "\(story.score ?? 0) points"),
                        sourceName: "Hacker News"
                    )
                }
            }
            
            var results: [NewsItem] = []
            for try await item in group {
                if let item = item {
                    results.append(item)
                }
            }
            return results.sorted { ($0.extra?.info ?? "") > ($1.extra?.info ?? "") }
        }
    }
}

private struct HackerNewsStory: Decodable {
    let id: Int
    let title: String
    let score: Int?
    let url: String?
}
