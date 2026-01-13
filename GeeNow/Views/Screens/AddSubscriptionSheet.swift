import SwiftUI

struct AddSubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var searchText = ""
    @State private var selectedType: RSSSourceType = .article
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typeFilterBar
                sourceList
            }
            .navigationTitle("添加订阅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .searchable(text: $searchText, prompt: "搜索\(selectedType.rawValue)源")
        }
    }
    
    private var typeFilterBar: some View {
        HStack(spacing: 0) {
            ForEach(RSSSourceType.allCases, id: \.self) { type in
                typeTab(type)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private func typeTab(_ type: RSSSourceType) -> some View {
        let isSelected = selectedType == type
        let subscribedCount = subscriptionManager.subscriptionCount(for: type)
        let totalCount = RSSSourceData.sources(for: type).count
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedType = type
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? typeColor(type) : Color(.systemGray5))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                Text(type.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? typeColor(type) : .secondary)
                
                Text("\(subscribedCount)/\(totalCount)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private func typeColor(_ type: RSSSourceType) -> Color {
        switch type {
        case .article: return .blue
        case .podcast: return .purple
        case .video: return .red
        case .twitter: return .cyan
        }
    }
    
    private var filteredSources: [RSSSource] {
        var sources = RSSSourceData.sources(for: selectedType)
        
        if !searchText.isEmpty {
            sources = sources.filter { source in
                source.name.localizedCaseInsensitiveContains(searchText) ||
                source.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return sources
    }
    
    private var groupedSources: [(RSSSourceCategory, [RSSSource])] {
        let grouped = Dictionary(grouping: filteredSources) { $0.category }
        return grouped.sorted { $0.value.count > $1.value.count }
    }
    
    private var sourceList: some View {
        List {
            ForEach(groupedSources, id: \.0) { category, sources in
                Section {
                    ForEach(sources) { source in
                        SubscriptionSourceRow(source: source, typeColor: typeColor(selectedType))
                    }
                } header: {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundColor(typeColor(selectedType))
                        Text(category.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(sources.count) 个源")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .textCase(nil)
                }
            }
            
            if filteredSources.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("未找到相关\(selectedType.rawValue)源")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct SubscriptionSourceRow: View {
    let source: RSSSource
    let typeColor: Color
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    private var isSubscribed: Bool {
        subscriptionManager.isSubscribed(source)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(typeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                if let icon = source.icon {
                    Text(icon)
                        .font(.title2)
                } else {
                    Image(systemName: source.type.icon)
                        .font(.title3)
                        .foregroundColor(typeColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(source.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(source.language.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(languageColor.opacity(0.15))
                        .foregroundColor(languageColor)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    subscriptionManager.toggleSubscription(source)
                }
            } label: {
                Image(systemName: isSubscribed ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundColor(isSubscribed ? .green : typeColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
    private var languageColor: Color {
        switch source.language {
        case .chinese: return .orange
        case .english: return .green
        case .bilingual: return .purple
        }
    }
}

#Preview {
    AddSubscriptionSheet()
}
