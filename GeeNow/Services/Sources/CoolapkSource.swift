import Foundation
import CryptoKit

struct CoolapkSource: NewsSourceProtocol {
    let source = Source(
        id: "coolapk",
        name: "酷安",
        colorName: "green",
        title: "今日热门",
        type: .hottest,
        interval: 600,
        home: "https://coolapk.com",
        column: .tech
    )
    
    func fetch() async throws -> [NewsItem] {
        guard let url = URL(string: "https://api.coolapk.com/v6/page/dataList?url=%2Ffeed%2FstatList%3FcacheExpires%3D300%26statType%3Dday%26sortField%3Ddetailnum%26title%3D%E4%BB%8A%E6%97%A5%E7%83%AD%E9%97%A8&title=%E4%BB%8A%E6%97%A5%E7%83%AD%E9%97%A8&subTitle=&page=1") else {
            throw NetworkError.invalidURL
        }
        
        let token = generateAppToken()
        
        let headers = [
            "User-Agent": "Dalvik/2.1.0 (Linux; U; Android 10; Redmi K30 5G MIUI/V12.0.3.0.QGICMXM) (#Build; Redmi; Redmi K30 5G; QKQ1.191222.002 test-keys; 10) +CoolMarket/11.0-2101202",
            "X-Requested-With": "XMLHttpRequest",
            "X-Sdk-Int": "29",
            "X-Sdk-Locale": "zh-CN",
            "X-App-Id": "com.coolapk.market",
            "X-App-Token": token,
            "X-App-Version": "11.0",
            "X-App-Code": "2101202",
            "X-Api-Version": "11",
            "Host": "api.coolapk.com"
        ]
        
        let response: CoolapkResponse = try await NetworkService.shared.fetch(url, headers: headers)
        
        guard !response.data.isEmpty else {
            throw NetworkError.invalidResponse
        }
        
        return response.data.compactMap { item -> NewsItem? in
            guard !item.id.isEmpty else { return nil }
            
            let title = item.editor_title.isEmpty ? extractText(from: item.message) : item.editor_title
            guard !title.isEmpty else { return nil }
            
            return NewsItem(
                id: item.id,
                title: title,
                url: "https://www.coolapk.com\(item.url)",
                mobileUrl: "https://www.coolapk.com\(item.url)",
                extra: .init(info: item.targetRow?.subTitle),
                content: extractText(from: item.message),
                sourceName: "酷安"
            )
        }
    }
    
    private func extractText(from html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .components(separatedBy: "\n")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func generateAppToken() -> String {
        // Generate random device ID like: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        let deviceId = generateDeviceId()
        let now = Int(Date().timeIntervalSince1970)
        let hexNow = "0x\(String(now, radix: 16))"
        let md5Now = md5(String(now))
        
        // token://com.coolapk.market/c67ef5943784d09750dcfbb31020f0ab?{md5(timestamp)}${deviceId}&com.coolapk.market
        let s = "token://com.coolapk.market/c67ef5943784d09750dcfbb31020f0ab?\(md5Now)$\(deviceId)&com.coolapk.market"
        let base64S = Data(s.utf8).base64EncodedString()
        let md5S = md5(base64S)
        
        // Final token: md5(base64(s)) + deviceId + hexTimestamp
        return md5S + deviceId + hexNow
    }
    
    private func generateDeviceId() -> String {
        let lengths = [8, 4, 4, 4, 12]
        let parts = lengths.map { length -> String in
            let chars = "0123456789abcdef"
            return String((0..<length).map { _ in chars.randomElement()! })
        }
        return parts.joined(separator: "-")
    }
    
    private func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

private struct CoolapkResponse: Decodable {
    let data: [CoolapkItem]
    
    struct CoolapkItem: Decodable {
        let id: String
        let message: String
        let editor_title: String
        let url: String
        let targetRow: TargetRow?
        
        struct TargetRow: Decodable {
            let subTitle: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case id, message, url
            case editor_title
            case targetRow
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let intId = try? container.decode(Int.self, forKey: .id) {
                id = String(intId)
            } else {
                id = (try? container.decode(String.self, forKey: .id)) ?? ""
            }
            message = (try? container.decode(String.self, forKey: .message)) ?? ""
            editor_title = (try? container.decode(String.self, forKey: .editor_title)) ?? ""
            url = (try? container.decode(String.self, forKey: .url)) ?? ""
            targetRow = try? container.decode(TargetRow.self, forKey: .targetRow)
        }
    }
}
