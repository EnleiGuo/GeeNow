import Foundation

struct NewsItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let url: String
    var mobileUrl: String?
    var pubDate: Date?
    var extra: NewsExtra?
    var content: String?
    var author: String?
    var sourceName: String?
    
    struct NewsExtra: Codable, Hashable {
        var hover: String?
        var info: String?
        var icon: String?
        var diff: Int?
    }
}
