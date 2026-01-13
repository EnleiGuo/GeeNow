import Foundation

protocol NewsSourceProtocol {
    var source: Source { get }
    func fetch() async throws -> [NewsItem]
}
