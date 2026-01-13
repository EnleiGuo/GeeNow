import Foundation

struct DouyinSource: NewsSourceProtocol {
    let source = Source(
        id: "douyin",
        name: "抖音",
        colorName: "gray",
        title: "热榜",
        type: .hottest,
        home: "https://www.douyin.com",
        column: .china
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://www.douyin.com/aweme/v1/web/hot/search/list/?device_platform=webapp&aid=6383&channel=channel_pc_web") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "Referer": "https://www.douyin.com/",
            "Accept": "application/json"
        ]
        
        let response: DouyinResponse = try await NetworkService.shared.fetch(url, headers: headers)
        
        return response.data.word_list.enumerated().map { index, item in
            NewsItem(
                id: "\(item.word)_\(index)",
                title: item.word,
                url: "https://www.douyin.com/search/\(item.word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? item.word)",
                extra: .init(
                    hover: nil,
                    info: item.hot_value > 0 ? formatNumber(item.hot_value) : nil
                ),
                sourceName: "抖音热榜"
            )
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 10000 {
            return String(format: "%.1f万", Double(num) / 10000)
        }
        return "\(num)"
    }
}

private struct DouyinResponse: Decodable {
    let data: DouyinData
    
    struct DouyinData: Decodable {
        let word_list: [DouyinItem]
    }
    
    struct DouyinItem: Decodable {
        let word: String
        let hot_value: Int
    }
}
