import SwiftUI

enum LayoutMode: String, CaseIterable {
    case list = "列表"
    case card = "卡片"
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .card: return "rectangle.grid.1x2"
        }
    }
}

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingSettings = false
    @State private var selectedArticle: SelectedArticle?
    @State private var selectedSourceURL: SelectedSourceURL?
    @State private var listScrollProxy: ScrollViewProxy?
    @State private var cardScrollProxy: ScrollViewProxy?
    @State private var selectedSourceId: String?
    @AppStorage("layoutMode") private var layoutMode: LayoutMode = .list
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryTabBar(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: Category.allCases
                )
                
                if !viewModel.currentSources.isEmpty {
                    SourcePillBar(
                        sources: viewModel.currentSources.map { $0.source },
                        selectedSourceId: $selectedSourceId,
                        onTap: { sourceId in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if layoutMode == .list {
                                    listScrollProxy?.scrollTo(sourceId, anchor: .top)
                                } else {
                                    cardScrollProxy?.scrollTo(sourceId, anchor: .center)
                                }
                            }
                        }
                    )
                }
                
                if layoutMode == .list {
                    listLayout
                } else {
                    cardLayout
                }
            }
            .navigationTitle("GeeNow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    layoutToggle
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsScreen()
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(item: article.item, sourceColor: article.sourceColor)
            }
            .sheet(item: $selectedSourceURL) { source in
                WebViewSheet(url: source.url, title: source.title)
            }
            .onChange(of: layoutMode) { _, newMode in
                if let sourceId = selectedSourceId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if newMode == .list {
                                listScrollProxy?.scrollTo(sourceId, anchor: .top)
                            } else {
                                cardScrollProxy?.scrollTo(sourceId, anchor: .center)
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                if let sourceId = selectedSourceId,
                   viewModel.currentSources.contains(where: { $0.source.id == sourceId }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if layoutMode == .list {
                                listScrollProxy?.scrollTo(sourceId, anchor: .top)
                            } else {
                                cardScrollProxy?.scrollTo(sourceId, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
    
    private var layoutToggle: some View {
        Menu {
            ForEach(LayoutMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        layoutMode = mode
                    }
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                }
            }
        } label: {
            Image(systemName: layoutMode.icon)
                .font(.system(size: 16, weight: .medium))
                .contentTransition(.symbolEffect(.replace))
        }
    }
    
    private var listLayout: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.currentSources) { sourceData in
                        NewsSection(
                            source: sourceData.source,
                            items: sourceData.items,
                            isLoading: sourceData.isLoading,
                            isFavorite: viewModel.favoritesManager.isFavorite(sourceData.source.id),
                            onRefresh: {
                                viewModel.refresh(sourceId: sourceData.source.id)
                            },
                            onSourceTap: {
                                if let home = sourceData.source.home, let url = URL(string: home) {
                                    selectedSourceURL = SelectedSourceURL(url: url, title: sourceData.source.name)
                                }
                            },
                            onToggleFavorite: {
                                viewModel.favoritesManager.toggleFavorite(sourceData.source.id)
                            },
                            onItemTap: { item in
                                var itemWithSource = item
                                itemWithSource.sourceName = sourceData.source.name
                                selectedArticle = SelectedArticle(item: itemWithSource, sourceColor: sourceData.source.color)
                            }
                        )
                        .id(sourceData.source.id)
                    }
                    
                    if viewModel.currentSources.isEmpty && !viewModel.isInitialLoading {
                        EmptyStateView(category: viewModel.selectedCategory)
                    }
                }
                .padding(.bottom, 30)
            }
            .refreshable {
                await viewModel.refreshAll()
            }
            .onAppear {
                listScrollProxy = proxy
            }
        }
    }
    
    private var cardLayout: some View {
        GeometryReader { geometry in
            if viewModel.currentSources.isEmpty && !viewModel.isInitialLoading {
                EmptyStateView(category: viewModel.selectedCategory)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(viewModel.currentSources) { sourceData in
                                NewsCardView(
                                    source: sourceData.source,
                                    items: sourceData.items,
                                    isLoading: sourceData.isLoading,
                                    isFavorite: viewModel.favoritesManager.isFavorite(sourceData.source.id),
                                    cardWidth: geometry.size.width - 32,
                                    cardHeight: geometry.size.height,
                                    onRefresh: {
                                        viewModel.refresh(sourceId: sourceData.source.id)
                                    },
                                    onSourceTap: {
                                        if let home = sourceData.source.home, let url = URL(string: home) {
                                            selectedSourceURL = SelectedSourceURL(url: url, title: sourceData.source.name)
                                        }
                                    },
                                    onToggleFavorite: {
                                        viewModel.favoritesManager.toggleFavorite(sourceData.source.id)
                                    },
                                    onItemTap: { item in
                                        var itemWithSource = item
                                        itemWithSource.sourceName = sourceData.source.name
                                        selectedArticle = SelectedArticle(item: itemWithSource, sourceColor: sourceData.source.color)
                                    }
                                )
                                .id(sourceData.source.id)
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal, 16)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .refreshable {
                        await viewModel.refreshAll()
                    }
                    .onAppear {
                        cardScrollProxy = proxy
                    }
                }
            }
        }
    }
}

struct SourcePillBar: View {
    let sources: [Source]
    @Binding var selectedSourceId: String?
    let onTap: (String) -> Void
    @Namespace private var pillAnimation
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sources) { source in
                        let isSelected = selectedSourceId == source.id
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedSourceId = source.id
                            }
                            onTap(source.id)
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isSelected ? .white : source.color)
                                    .frame(width: 6, height: 6)
                                Text(source.name)
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                    .foregroundColor(isSelected ? .white : .primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(source.color)
                                        .matchedGeometryEffect(id: "selectedPill", in: pillAnimation)
                                } else {
                                    Capsule()
                                        .fill(Color(.secondarySystemBackground))
                                }
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .id(source.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: selectedSourceId) { _, newValue in
                if let id = newValue {
                    withAnimation(.spring(response: 0.3)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }
}

struct SelectedArticle: Identifiable {
    let id = UUID()
    let item: NewsItem
    let sourceColor: Color
}

struct SelectedSourceURL: Identifiable {
    let id = UUID()
    let url: URL
    let title: String
}

private struct EmptyStateView: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category == .focus ? "star" : "newspaper")
                .font(.system(size: 48))
                .foregroundColor(category == .focus ? .yellow.opacity(0.6) : .secondary.opacity(0.5))
            Text(category == .focus ? "暂无关注的新闻源" : "暂无\(category.rawValue)内容")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(category == .focus ? "点击新闻源旁的 ☆ 添加关注" : "请尝试切换其他分类")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HomeScreen()
}
