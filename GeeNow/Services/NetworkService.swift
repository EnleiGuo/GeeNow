import Foundation

actor NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let defaultHeaders: [String: String] = [
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,application/json,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Cache-Control": "no-cache"
    ]
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetch<T: Decodable>(_ url: URL, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        for (key, value) in defaultHeaders.merging(headers, uniquingKeysWith: { _, new in new }) {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(T.self, from: data)
        } catch {
            // 打印原始响应帮助调试
            if let rawString = String(data: data, encoding: .utf8) {
                print("⚠️ [NetworkService] JSON decode failed. Raw response first 500 chars:")
                print(String(rawString.prefix(500)))
            }
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchHTML(_ url: URL, headers: [String: String] = [:]) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        for (key, value) in defaultHeaders.merging(headers, uniquingKeysWith: { _, new in new }) {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingFailed(NSError(domain: "UTF8", code: -1))
        }
        
        return html
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP错误: \(statusCode)"
        case .decodingFailed(let error):
            return "解析失败: \(error.localizedDescription)"
        }
    }
}
