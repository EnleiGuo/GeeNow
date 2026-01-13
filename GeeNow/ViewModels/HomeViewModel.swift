import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sourceDataMap: [String: SourceData] = [:]
    @Published var selectedCategory: Category = .hottest
    @Published var isInitialLoading = true
    
    private let newsService = NewsService.shared
    let favoritesManager = FavoritesManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Forward FavoritesManager changes to trigger UI updates
        favoritesManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    struct SourceData: Identifiable {
        let id: String
        let source: Source
        var items: [NewsItem] = []
        var isLoading = false
        var lastUpdated: Date?
        var error: Error?
    }
    
    var currentSources: [SourceData] {
        if selectedCategory == .focus {
            return favoritesManager.favoriteIds
                .compactMap { sourceDataMap[$0] }
                .sorted { $0.source.name < $1.source.name }
        }
        return newsService.sources(for: selectedCategory)
            .compactMap { sourceDataMap[$0.id] }
            .sorted { $0.source.name < $1.source.name }
    }
    
    var allSourceIds: [String] {
        newsService.allSources.map { $0.id }
    }
    
    func loadInitialData() async {
        guard isInitialLoading else { return }
        
        for source in newsService.allSources {
            sourceDataMap[source.id] = SourceData(
                id: source.id,
                source: source,
                isLoading: true
            )
        }
        
        await withTaskGroup(of: (String, [NewsItem]?, Error?).self) { group in
            for source in newsService.allSources {
                group.addTask { [weak self] in
                    do {
                        let items = try await self?.newsService.fetch(sourceId: source.id) ?? []
                        print("✅ [\(source.id)] Fetched \(items.count) items")
                        return (source.id, items, nil)
                    } catch {
                        print("❌ [\(source.id)] Error: \(error)")
                        return (source.id, nil, error)
                    }
                }
            }
            
            for await (sourceId, items, error) in group {
                if var data = sourceDataMap[sourceId] {
                    if let items = items {
                        data.items = items
                    }
                    data.isLoading = false
                    data.lastUpdated = Date()
                    data.error = error
                    sourceDataMap[sourceId] = data
                }
            }
        }
        
        isInitialLoading = false
    }
    
    func refresh(sourceId: String) {
        Task {
            await performRefresh(sourceId: sourceId)
        }
    }
    
    private func performRefresh(sourceId: String) async {
        sourceDataMap[sourceId]?.isLoading = true
        
        do {
            let items = try await newsService.fetch(sourceId: sourceId)
            print("✅ [\(sourceId)] Refreshed \(items.count) items")
            sourceDataMap[sourceId]?.items = items
            sourceDataMap[sourceId]?.lastUpdated = Date()
            sourceDataMap[sourceId]?.error = nil
        } catch {
            print("❌ [\(sourceId)] Refresh error: \(error)")
            sourceDataMap[sourceId]?.error = error
        }
        
        sourceDataMap[sourceId]?.isLoading = false
    }
    
    func refreshAll() async {
        let sourcesToRefresh = newsService.sources(for: selectedCategory)
        
        await withTaskGroup(of: Void.self) { group in
            for source in sourcesToRefresh {
                group.addTask {
                    await self.performRefresh(sourceId: source.id)
                }
            }
        }
    }
}
