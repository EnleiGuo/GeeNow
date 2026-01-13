import Foundation
import Combine

@MainActor
class ReadingViewModel: ObservableObject {
    @Published var articles: [RSSArticle] = []
    @Published var displayedArticles: [RSSArticle] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var selectedCategory: RSSCategory = .all
    @Published var showFeaturedOnly = false
    @Published var errorMessage: String?
    @Published var hasMoreData = true
    
    private let pageSize = 10
    private var currentPage = 0
    private var currentLoadingTask: Task<Void, Never>?
    private var loadingRequestID: UUID?
    
    func loadInitialData() async {
        if let cached = await BestBlogsService.shared.loadFromCache(
            category: selectedCategory,
            featured: showFeaturedOnly,
            minScore: showFeaturedOnly ? 85 : nil,
            timeFilter: "1w"
        ) {
            articles = cached
            displayedArticles = Array(cached.prefix(pageSize))
            currentPage = 1
            hasMoreData = cached.count > pageSize
        }
        
        if articles.isEmpty {
            await refresh()
        }
    }
    
    func onCategoryChanged() {
        currentLoadingTask?.cancel()
        
        articles = []
        displayedArticles = []
        currentPage = 0
        hasMoreData = true
        errorMessage = nil
        
        currentLoadingTask = Task {
            await refresh()
        }
    }
    
    func onFeaturedChanged() {
        currentLoadingTask?.cancel()
        
        articles = []
        displayedArticles = []
        currentPage = 0
        hasMoreData = true
        errorMessage = nil
        
        currentLoadingTask = Task {
            await refresh()
        }
    }
    
    func refresh(forceRefresh: Bool = false) async {
        let requestID = UUID()
        loadingRequestID = requestID
        
        isLoading = true
        errorMessage = nil
        currentPage = 0
        
        do {
            let fetchedArticles = try await BestBlogsService.shared.fetchArticles(
                category: selectedCategory,
                featured: showFeaturedOnly,
                minScore: showFeaturedOnly ? 85 : nil,
                timeFilter: "1w",
                forceRefresh: forceRefresh
            )
            
            guard loadingRequestID == requestID else { return }
            
            articles = fetchedArticles
            displayedArticles = Array(fetchedArticles.prefix(pageSize))
            currentPage = 1
            hasMoreData = fetchedArticles.count > pageSize
        } catch {
            guard loadingRequestID == requestID else { return }
            if !Task.isCancelled {
                errorMessage = "加载失败: \(error.localizedDescription)"
            }
        }
        
        guard loadingRequestID == requestID else { return }
        isLoading = false
    }
    
    func loadMore() {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, articles.count)
        
        if startIndex < articles.count {
            let newArticles = Array(articles[startIndex..<endIndex])
            displayedArticles.append(contentsOf: newArticles)
            currentPage += 1
            hasMoreData = endIndex < articles.count
        } else {
            hasMoreData = false
        }
        
        isLoadingMore = false
    }
}
