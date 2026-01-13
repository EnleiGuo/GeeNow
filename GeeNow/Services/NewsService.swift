import Foundation

@MainActor
class NewsService: ObservableObject {
    static let shared = NewsService()
    
    private let allSourceProviders: [any NewsSourceProtocol] = [
        WeiboSource(),
        ZhihuSource(),
        ToutiaoSource(),
        DouyinSource(),
        BilibiliSource(),
        BaiduSource(),
        ThepaperSource(),
        HupuSource(),
        TiebaSource(),
        DoubanSource(),
        IfengSource(),
        V2exSource(),
        ITHomeSource(),
        JuejinSource(),
        Kr36Source(),
        SspaiSource(),
        CoolapkSource(),
        CNBetaSource(),
        HackernewsSource(),
        GithubSource(),
        WallstreetcnSource(),
        ClsSource(),
        Jin10Source(),
        XueqiuSource()
    ]
    
    var allSources: [Source] {
        allSourceProviders.map { $0.source }
    }
    
    func sources(for category: Category) -> [Source] {
        switch category {
        case .focus:
            return []
        case .hottest:
            return allSources.filter { $0.type == .hottest }
        case .realtime:
            return allSources.filter { $0.type == .realtime }
        default:
            return allSources.filter { $0.column == category }
        }
    }
    
    func fetch(sourceId: String) async throws -> [NewsItem] {
        guard let provider = allSourceProviders.first(where: { $0.source.id == sourceId }) else {
            throw NewsServiceError.sourceNotFound
        }
        return try await provider.fetch()
    }
    
    func source(for id: String) -> Source? {
        allSources.first { $0.id == id }
    }
}

enum NewsServiceError: LocalizedError {
    case sourceNotFound
    
    var errorDescription: String? {
        switch self {
        case .sourceNotFound:
            return "未找到新闻源"
        }
    }
}
