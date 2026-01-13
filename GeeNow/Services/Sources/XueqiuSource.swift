import Foundation

struct XueqiuSource: NewsSourceProtocol {
    let source = Source(
        id: "xueqiu",
        name: "雪球",
        colorName: "blue",
        title: "热股",
        type: .hottest,
        interval: 120,
        home: "https://xueqiu.com",
        column: .finance
    )
    
    func fetch() async throws -> [NewsItem] {
        // Step 1: Fetch the main page to get cookies
        guard let mainURL = URL(string: "https://xueqiu.com/hq") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: mainURL)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Extract cookies from Set-Cookie headers
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as? [String: String] ?? [:], for: mainURL)
        let cookieString = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
        
        guard !cookieString.isEmpty else {
            throw NetworkError.invalidResponse
        }
        
        // Step 2: Use cookies to fetch the API
        guard let apiURL = URL(string: "https://stock.xueqiu.com/v5/stock/hot_stock/list.json?size=30&_type=10&type=10") else {
            throw NetworkError.invalidURL
        }
        
        let headers = [
            "Cookie": cookieString,
            "Origin": "https://xueqiu.com",
            "Referer": "https://xueqiu.com/hq",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        ]
        
        let stockResponse: XueqiuResponse = try await NetworkService.shared.fetch(apiURL, headers: headers)
        
        return stockResponse.data.items.filter { $0.ad != 1 }.map { item in
            let changeStr: String
            if item.percent >= 0 {
                changeStr = "+\(String(format: "%.2f", item.percent))%"
            } else {
                changeStr = "\(String(format: "%.2f", item.percent))%"
            }
            
            return NewsItem(
                id: item.code,
                title: item.name,
                url: "https://xueqiu.com/s/\(item.code)",
                mobileUrl: "https://xueqiu.com/s/\(item.code)",
                extra: .init(info: "\(changeStr) \(item.exchange)"),
                sourceName: "雪球热股"
            )
        }
    }
}

private struct XueqiuResponse: Decodable {
    let data: XueqiuData
    
    struct XueqiuData: Decodable {
        let items: [XueqiuStock]
    }
    
    struct XueqiuStock: Decodable {
        let code: String
        let name: String
        let percent: Double
        let exchange: String
        let ad: Int?
        
        enum CodingKeys: String, CodingKey {
            case code, name, percent, exchange, ad
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(String.self, forKey: .code)
            name = try container.decode(String.self, forKey: .name)
            percent = (try? container.decode(Double.self, forKey: .percent)) ?? 0
            exchange = (try? container.decode(String.self, forKey: .exchange)) ?? ""
            ad = try? container.decode(Int.self, forKey: .ad)
        }
    }
}
