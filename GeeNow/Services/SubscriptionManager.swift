import Foundation
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscribedSourceIds: Set<String> = []
    @Published private(set) var isInitialized = false
    
    private let userDefaultsKey = "subscribedRSSSources"
    private let hasLaunchedKey = "hasLaunchedBefore"
    
    private init() {
        loadSubscriptions()
    }
    
    var subscribedSources: [RSSSource] {
        RSSSourceData.allSources.filter { subscribedSourceIds.contains($0.id) }
    }
    
    func subscribedSources(for type: RSSSourceType) -> [RSSSource] {
        subscribedSources.filter { $0.type == type }
    }
    
    func isSubscribed(_ source: RSSSource) -> Bool {
        subscribedSourceIds.contains(source.id)
    }
    
    func isSubscribed(sourceId: String) -> Bool {
        subscribedSourceIds.contains(sourceId)
    }
    
    func subscribe(_ source: RSSSource) {
        guard !subscribedSourceIds.contains(source.id) else { return }
        subscribedSourceIds.insert(source.id)
        saveSubscriptions()
    }
    
    func unsubscribe(_ source: RSSSource) {
        guard subscribedSourceIds.contains(source.id) else { return }
        subscribedSourceIds.remove(source.id)
        saveSubscriptions()
    }
    
    func toggleSubscription(_ source: RSSSource) {
        if isSubscribed(source) {
            unsubscribe(source)
        } else {
            subscribe(source)
        }
    }
    
    func subscribeMultiple(_ sources: [RSSSource]) {
        for source in sources {
            subscribedSourceIds.insert(source.id)
        }
        saveSubscriptions()
    }
    
    func unsubscribeAll() {
        subscribedSourceIds.removeAll()
        saveSubscriptions()
    }
    
    private func loadSubscriptions() {
        let hasLaunched = UserDefaults.standard.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            subscribedSourceIds = RSSSourceData.defaultSubscribedSourceIds
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            saveSubscriptions()
        } else {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
               let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
                subscribedSourceIds = ids
            }
        }
        
        isInitialized = true
    }
    
    private func saveSubscriptions() {
        if let data = try? JSONEncoder().encode(subscribedSourceIds) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}

extension SubscriptionManager {
    var subscribedArticleSources: [RSSSource] {
        subscribedSources(for: .article)
    }
    
    var subscribedPodcastSources: [RSSSource] {
        subscribedSources(for: .podcast)
    }
    
    var subscribedVideoSources: [RSSSource] {
        subscribedSources(for: .video)
    }
    
    var subscribedTwitterSources: [RSSSource] {
        subscribedSources(for: .twitter)
    }
    
    var hasSubscriptions: Bool {
        !subscribedSourceIds.isEmpty
    }
    
    var subscriptionCount: Int {
        subscribedSourceIds.count
    }
    
    func subscriptionCount(for type: RSSSourceType) -> Int {
        subscribedSources(for: type).count
    }
}
