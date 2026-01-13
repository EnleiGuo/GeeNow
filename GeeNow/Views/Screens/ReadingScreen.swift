import SwiftUI
import SafariServices

struct ReadingScreen: View {
    @StateObject private var viewModel = ReadingViewModel()
    @State private var selectedArticle: RSSArticle?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterTabBar(
                    selection: $viewModel.selectedCategory,
                    items: RSSCategory.allCases,
                    titleProvider: { $0.rawValue }
                )
                .onChange(of: viewModel.selectedCategory) { _, _ in
                    viewModel.onCategoryChanged()
                }
                
                if viewModel.isLoading && viewModel.displayedArticles.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.displayedArticles.isEmpty {
                    errorView(error)
                } else {
                    articleList
                }
            }
            .navigationTitle("阅读")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    featuredToggle
                }
            }
            .sheet(item: $selectedArticle) { article in
                RSSArticleDetailView(article: article)
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
    
    private var featuredToggle: some View {
        Button {
            viewModel.showFeaturedOnly.toggle()
            viewModel.onFeaturedChanged()
        } label: {
            Image(systemName: viewModel.showFeaturedOnly ? "star.fill" : "star")
                .foregroundColor(viewModel.showFeaturedOnly ? .yellow : .primary)
        }
        .disabled(viewModel.isLoading)
    }
    
    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.displayedArticles) { article in
                    RSSArticleRow(article: article) {
                        selectedArticle = article
                    }
                    .onAppear {
                        if article.id == viewModel.displayedArticles.last?.id {
                            viewModel.loadMore()
                        }
                    }
                    Divider().padding(.leading, 16)
                }
                
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else if !viewModel.hasMoreData && !viewModel.displayedArticles.isEmpty {
                    Text("没有更多了")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.bottom, 20)
        }
        .refreshable {
            await viewModel.refresh(forceRefresh: true)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("重试") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RSSArticleRow: View {
    let article: RSSArticle
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        if let author = article.author {
                            Text(author)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        if let category = article.category {
                            Text(category)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if let score = article.scoreText {
                            Text(score)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                        Text(article.displayDate)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = .systemBlue
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct RSSArticleDetailView: View {
    let article: RSSArticle
    @Environment(\.dismiss) private var dismiss
    @State private var showSafari = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    metaSection
                    
                    Text(article.title)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let author = article.author {
                        Text("By \(author)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    if let content = article.content, !content.isEmpty {
                        Text(content)
                            .font(.system(size: 16))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    } else if let description = article.description {
                        Text(description)
                            .font(.system(size: 16))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    viewOriginalButton
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSafari = true
                    } label: {
                        Image(systemName: "safari")
                    }
                }
            }
            .fullScreenCover(isPresented: $showSafari) {
                if let url = URL(string: article.link) {
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
    }
    
    private var metaSection: some View {
        HStack(spacing: 8) {
            if let category = article.category {
                Text(category)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            if let score = article.scoreText {
                Text("•")
                    .foregroundColor(.secondary)
                Text(score)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            Text("•")
                .foregroundColor(.secondary)
            Text(article.displayDate)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
    
    private var viewOriginalButton: some View {
        Button {
            showSafari = true
        } label: {
            HStack {
                Image(systemName: "safari")
                Text("查看原文")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.top, 20)
    }
}
