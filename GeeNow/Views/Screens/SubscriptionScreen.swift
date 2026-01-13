import SwiftUI

struct SubscriptionScreen: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showAddSheet = false
    @State private var selectedType: RSSSourceType = .article
    @State private var selectedSourceId: String?
    @State private var listScrollProxy: ScrollViewProxy?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typeTabBar
                
                if !viewModel.currentSources.isEmpty {
                    sourcePillBar
                }
                
                if viewModel.currentSources.isEmpty && !viewModel.isLoading {
                    emptySubscriptionView
                } else {
                    contentList
                }
            }
            .navigationTitle("订阅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                Task {
                    await viewModel.reloadSourcesWithCache()
                }
            }) {
                AddSubscriptionSheet()
            }
            .refreshable {
                await viewModel.refreshAll()
            }
            .task {
                await viewModel.loadInitialData()
            }
            .onChange(of: selectedType) { _, _ in
                viewModel.selectedType = selectedType
            }
        }
    }
    
    private var typeTabBar: some View {
        HStack(spacing: 0) {
            ForEach(RSSSourceType.allCases, id: \.self) { type in
                typeTab(type)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .overlay(
            Divider()
                .opacity(0.5),
            alignment: .bottom
        )
    }
    
    private func typeTab(_ type: RSSSourceType) -> some View {
        let isSelected = selectedType == type
        let count = viewModel.sourceCount(for: type)
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedType = type
                selectedSourceId = nil
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
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isSelected ? typeColor(type) : .white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white : typeColor(type))
                            .clipShape(Capsule())
                            .offset(x: 16, y: -16)
                    }
                }
                
                Text(type.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? typeColor(type) : .secondary)
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
    
    private var sourcePillBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.currentSources) { sourceData in
                        let isSelected = selectedSourceId == sourceData.source.id
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedSourceId = sourceData.source.id
                            }
                            listScrollProxy?.scrollTo(sourceData.source.id, anchor: .top)
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isSelected ? .white : typeColor(selectedType))
                                    .frame(width: 6, height: 6)
                                Text(sourceData.source.name)
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                    .foregroundColor(isSelected ? .white : .primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? typeColor(selectedType) : Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(SubscriptionScaleButtonStyle())
                        .id(sourceData.source.id)
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
    
    private var contentList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.currentSources) { sourceData in
                        SubscriptionSourceSection(
                            sourceData: sourceData,
                            typeColor: typeColor(selectedType),
                            onRefresh: {
                                viewModel.refresh(sourceId: sourceData.source.id)
                            }
                        )
                        .id(sourceData.source.id)
                    }
                    
                    if viewModel.currentSources.isEmpty && viewModel.isLoading {
                        SubscriptionLoadingPlaceholder()
                            .padding(.top, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .onAppear {
                listScrollProxy = proxy
            }
        }
    }
    
    private var emptySubscriptionView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "plus.rectangle.on.folder")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("暂无\(selectedType.rawValue)订阅")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("点击右上角 + 添加订阅源")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
            Button {
                showAddSheet = true
            } label: {
                Text("添加订阅")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(typeColor(selectedType))
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SubscriptionSourceSection: View {
    let sourceData: SubscriptionSourceData
    let typeColor: Color
    let onRefresh: () -> Void
    
    @State private var showAll = false
    private let initialCount = 10
    
    var displayItems: [SubscriptionItem] {
        showAll ? Array(sourceData.items.prefix(30)) : Array(sourceData.items.prefix(initialCount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            
            if sourceData.items.isEmpty && sourceData.isLoading {
                SubscriptionLoadingPlaceholder()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                        SubscriptionItemRow(
                            item: item,
                            index: index + 1,
                            sourceColor: typeColor,
                            showDivider: index < displayItems.count - 1
                        )
                    }
                    
                    if sourceData.items.count > initialCount {
                        expandButton
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var sectionHeader: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(typeColor.opacity(0.15))
                    Text(String(sourceData.source.name.prefix(1)))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(typeColor)
                }
                .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(sourceData.source.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(sourceData.source.language.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(typeColor)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(typeColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text("\(sourceData.items.count) 条内容")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            SubscriptionRefreshButton(isLoading: sourceData.isLoading, color: typeColor, action: onRefresh)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var expandButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showAll.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Text(showAll ? "收起" : "展开更多")
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: showAll ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

struct SubscriptionItemRow: View {
    let item: SubscriptionItem
    let index: Int
    let sourceColor: Color
    let showDivider: Bool
    
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                showDetail = true
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    rankBadge
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 6) {
                            if let date = item.pubDate {
                                Text(formatRelativeDate(date))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            if case .podcast(let podcast) = item, let duration = podcast.durationText {
                                Text("·")
                                    .foregroundColor(.secondary)
                                Text(duration)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer(minLength: 4)
                    
                    typeIcon
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(SubscriptionRowButtonStyle())
            
            if showDivider {
                Divider().padding(.leading, 44)
            }
        }
        .sheet(isPresented: $showDetail) {
            itemDetailView
        }
    }
    
    @ViewBuilder
    private var rankBadge: some View {
        if index <= 3 {
            Text("\(index)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(rankColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        } else {
            Text("\(index)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .center)
        }
    }
    
    private var rankColor: Color {
        switch index {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .secondary
        }
    }
    
    @ViewBuilder
    private var typeIcon: some View {
        switch item {
        case .article:
            Image(systemName: "doc.text").foregroundColor(.blue).font(.system(size: 12))
        case .podcast:
            Image(systemName: "mic.fill").foregroundColor(.purple).font(.system(size: 12))
        case .video:
            Image(systemName: "play.rectangle.fill").foregroundColor(.red).font(.system(size: 12))
        case .tweet:
            Image(systemName: "bubble.left.fill").foregroundColor(.cyan).font(.system(size: 12))
        }
    }
    
    @ViewBuilder
    private var itemDetailView: some View {
        switch item {
        case .article(let article):
            if let url = URL(string: article.link) {
                SafariView(url: url)
            }
        case .podcast(let podcast):
            PodcastDetailSheet(item: podcast)
        case .video(let video):
            VideoPlayerSheet(item: video)
        case .tweet(let tweet):
            TweetDetailSheet(item: tweet)
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PodcastDetailSheet: View {
    let item: PodcastItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioPlayer: AudioPlayerManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let coverURL = item.coverImageURL, let url = URL(string: coverURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.purple.opacity(0.2)
                    }
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                VStack(spacing: 8) {
                    Text(item.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(item.sourceName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let duration = item.durationText {
                        Text(duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Button {
                    audioPlayer.play(item)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("播放")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .disabled(item.audioURL == nil)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct TweetDetailSheet: View {
    let item: TweetItem
    @Environment(\.dismiss) private var dismiss
    @State private var showSafari = false
    
    private var cleanContent: String {
        stripHTML(item.content)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.cyan.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Text(String(item.authorName.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.cyan)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.authorName)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(item.authorHandle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text(cleanContent)
                        .font(.body)
                        .lineSpacing(4)
                    
                    if let mediaURLs = item.mediaURLs, !mediaURLs.isEmpty {
                        mediaGrid(mediaURLs)
                    }
                    
                    Text(formatFullDate(item.pubDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack(spacing: 24) {
                        if let replyText = item.replyText {
                            statItem(icon: "bubble.left", text: replyText, label: "回复")
                        }
                        if let retweetText = item.retweetText {
                            statItem(icon: "arrow.2.squarepath", text: retweetText, label: "转发")
                        }
                        if let likeText = item.likeText {
                            statItem(icon: "heart", text: likeText, label: "喜欢")
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer(minLength: 20)
                    
                    Button {
                        showSafari = true
                    } label: {
                        HStack {
                            Image(systemName: "safari")
                            Text("在浏览器中查看")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showSafari) {
                if let url = URL(string: item.link) {
                    SafariView(url: url)
                }
            }
        }
    }
    
    private func statItem(icon: String, text: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text(label)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private func mediaGrid(_ urls: [String]) -> some View {
        let validURLs = urls.compactMap { URL(string: $0) }
        
        if validURLs.count == 1, let url = validURLs.first {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(Color(.systemGray5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if validURLs.count >= 2 {
            HStack(spacing: 4) {
                ForEach(validURLs.prefix(2), id: \.absoluteString) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(Color(.systemGray5))
                        }
                    }
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func formatFullDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
    
    private func stripHTML(_ string: String) -> String {
        var result = string
        
        result = result.replacingOccurrences(of: "<![CDATA[", with: "")
        result = result.replacingOccurrences(of: "]]>", with: "")
        
        if let data = result.data(using: .utf8),
           let attributed = try? NSAttributedString(
               data: data,
               options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ],
               documentAttributes: nil
           ) {
            result = attributed.string
        } else {
            if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    options: [],
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: ""
                )
            }
        }
        
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&apos;", with: "'")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct SubscriptionRefreshButton: View {
    let isLoading: Bool
    let color: Color
    let action: () -> Void
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .rotationEffect(.degrees(rotation))
        }
        .disabled(isLoading)
        .onChange(of: isLoading) { _, newValue in
            if newValue {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            } else {
                withAnimation(.spring(response: 0.3)) {
                    rotation = 0
                }
            }
        }
    }
}

struct SubscriptionLoadingPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 20, height: 20)
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.12))
                            .frame(height: 14)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.08))
                            .frame(width: 80, height: 10)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
    }
}

private struct SubscriptionScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct SubscriptionRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - ViewModel

struct SubscriptionSourceData: Identifiable {
    let source: RSSSource
    var items: [SubscriptionItem]
    var isLoading: Bool
    
    var id: String { source.id }
}

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published private(set) var sourcesData: [RSSSourceType: [SubscriptionSourceData]] = [:]
    @Published private(set) var isLoading = false
    @Published var selectedType: RSSSourceType = .article
    
    private let subscriptionManager = SubscriptionManager.shared
    private let cache = SubscriptionCache.shared
    
    var currentSources: [SubscriptionSourceData] {
        sourcesData[selectedType] ?? []
    }
    
    func sourceCount(for type: RSSSourceType) -> Int {
        subscriptionManager.subscriptionCount(for: type)
    }
    
    func loadInitialData() async {
        await reloadSources()
        
        loadFromCache()
        
        if cache.shouldRefresh() {
            await refreshAll()
        }
    }
    
    private func loadFromCache() {
        for type in RSSSourceType.allCases {
            guard var typeData = sourcesData[type] else { continue }
            
            for i in typeData.indices {
                let cachedItems = cache.getItems(for: typeData[i].source.id)
                if !cachedItems.isEmpty {
                    typeData[i].items = cachedItems
                }
            }
            sourcesData[type] = typeData
        }
    }
    
    func reloadSources() async {
        var newData: [RSSSourceType: [SubscriptionSourceData]] = [:]
        
        for type in RSSSourceType.allCases {
            let sources = subscriptionManager.subscribedSources(for: type)
            newData[type] = sources.map { SubscriptionSourceData(source: $0, items: [], isLoading: false) }
        }
        
        sourcesData = newData
    }
    
    func reloadSourcesWithCache() async {
        var newData: [RSSSourceType: [SubscriptionSourceData]] = [:]
        
        for type in RSSSourceType.allCases {
            let sources = subscriptionManager.subscribedSources(for: type)
            newData[type] = sources.map { source in
                let cachedItems = cache.getItems(for: source.id)
                return SubscriptionSourceData(source: source, items: cachedItems, isLoading: false)
            }
        }
        
        sourcesData = newData
        
        let hasNewSources = newData.values.flatMap { $0 }.contains { $0.items.isEmpty }
        if hasNewSources {
            await refreshAll()
        }
    }
    
    func refreshAll() async {
        isLoading = true
        
        for type in RSSSourceType.allCases {
            guard var typeData = sourcesData[type] else { continue }
            
            for i in typeData.indices {
                typeData[i].isLoading = true
            }
            sourcesData[type] = typeData
            
            await withTaskGroup(of: (Int, [SubscriptionItem]?).self) { group in
                for (index, sourceData) in typeData.enumerated() {
                    group.addTask {
                        do {
                            let items = try await RSSFeedService.shared.fetchItems(from: sourceData.source)
                            return (index, items)
                        } catch {
                            print("Failed to fetch \(sourceData.source.name): \(error)")
                            return (index, nil)
                        }
                    }
                }
                
                for await (index, items) in group {
                    if var currentTypeData = sourcesData[type], index < currentTypeData.count {
                        if let items = items {
                            currentTypeData[index].items = items
                            cache.saveItems(items, for: currentTypeData[index].source.id)
                        }
                        currentTypeData[index].isLoading = false
                        sourcesData[type] = currentTypeData
                    }
                }
            }
        }
        
        cache.updateLastRefreshTime()
        isLoading = false
    }
    
    func refresh(sourceId: String) {
        Task {
            for type in RSSSourceType.allCases {
                guard var typeData = sourcesData[type],
                      let index = typeData.firstIndex(where: { $0.source.id == sourceId }) else { continue }
                
                typeData[index].isLoading = true
                sourcesData[type] = typeData
                
                do {
                    let items = try await RSSFeedService.shared.fetchItems(from: typeData[index].source)
                    typeData[index].items = items
                    cache.saveItems(items, for: sourceId)
                } catch {
                    print("Failed to refresh \(sourceId): \(error)")
                }
                
                typeData[index].isLoading = false
                sourcesData[type] = typeData
                break
            }
        }
    }
}

class SubscriptionCache {
    static let shared = SubscriptionCache()
    
    private let defaults = UserDefaults.standard
    private let cacheExpirationMinutes: Double = 15
    private let lastRefreshKey = "subscription_last_refresh"
    
    private var memoryCache: [String: [SubscriptionItem]] = [:]
    
    private init() {
        loadFromDisk()
    }
    
    func shouldRefresh() -> Bool {
        guard let lastRefresh = defaults.object(forKey: lastRefreshKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastRefresh) > cacheExpirationMinutes * 60
    }
    
    func updateLastRefreshTime() {
        defaults.set(Date(), forKey: lastRefreshKey)
    }
    
    func getItems(for sourceId: String) -> [SubscriptionItem] {
        return memoryCache[sourceId] ?? []
    }
    
    func saveItems(_ items: [SubscriptionItem], for sourceId: String) {
        memoryCache[sourceId] = items
        saveToDisk()
    }
    
    private func saveToDisk() {
        var diskCache: [String: [[String: Any]]] = [:]
        
        for (sourceId, items) in memoryCache {
            diskCache[sourceId] = items.map { encodeItem($0) }
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: diskCache) {
            defaults.set(data, forKey: "subscription_cache")
        }
    }
    
    private func loadFromDisk() {
        guard let data = defaults.data(forKey: "subscription_cache"),
              let diskCache = try? JSONSerialization.jsonObject(with: data) as? [String: [[String: Any]]] else {
            return
        }
        
        for (sourceId, itemDicts) in diskCache {
            memoryCache[sourceId] = itemDicts.compactMap { decodeItem($0) }
        }
    }
    
    private func encodeItem(_ item: SubscriptionItem) -> [String: Any] {
        var dict: [String: Any] = ["type": item.itemType.rawValue]
        
        switch item {
        case .article(let a):
            dict["id"] = a.id
            dict["title"] = a.title
            dict["sourceId"] = a.sourceId
            dict["sourceName"] = a.sourceName
            dict["pubDate"] = a.pubDate?.timeIntervalSince1970
            dict["link"] = a.link
            dict["summary"] = a.summary
            dict["imageURL"] = a.imageURL
            dict["author"] = a.author
        case .podcast(let p):
            dict["id"] = p.id
            dict["title"] = p.title
            dict["sourceId"] = p.sourceId
            dict["sourceName"] = p.sourceName
            dict["pubDate"] = p.pubDate?.timeIntervalSince1970
            dict["link"] = p.link
            dict["audioURL"] = p.audioURL
            dict["duration"] = p.duration
            dict["coverImageURL"] = p.coverImageURL
            dict["description"] = p.description
        case .video(let v):
            dict["id"] = v.id
            dict["title"] = v.title
            dict["sourceId"] = v.sourceId
            dict["sourceName"] = v.sourceName
            dict["pubDate"] = v.pubDate?.timeIntervalSince1970
            dict["link"] = v.link
            dict["videoURL"] = v.videoURL
            dict["thumbnailURL"] = v.thumbnailURL
            dict["duration"] = v.duration
            dict["channelName"] = v.channelName
        case .tweet(let t):
            dict["id"] = t.id
            dict["title"] = t.title
            dict["sourceId"] = t.sourceId
            dict["sourceName"] = t.sourceName
            dict["pubDate"] = t.pubDate?.timeIntervalSince1970
            dict["link"] = t.link
            dict["content"] = t.content
            dict["authorName"] = t.authorName
            dict["authorHandle"] = t.authorHandle
        }
        
        return dict
    }
    
    private func decodeItem(_ dict: [String: Any]) -> SubscriptionItem? {
        guard let typeRaw = dict["type"] as? String,
              let type = RSSSourceType(rawValue: typeRaw),
              let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let sourceId = dict["sourceId"] as? String,
              let sourceName = dict["sourceName"] as? String,
              let link = dict["link"] as? String else {
            return nil
        }
        
        let pubDate: Date? = (dict["pubDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
        
        switch type {
        case .article:
            return .article(ArticleItem(
                id: id, title: title, sourceId: sourceId, sourceName: sourceName,
                pubDate: pubDate, link: link,
                summary: dict["summary"] as? String,
                content: nil,
                imageURL: dict["imageURL"] as? String,
                author: dict["author"] as? String,
                score: nil
            ))
        case .podcast:
            return .podcast(PodcastItem(
                id: id, title: title, sourceId: sourceId, sourceName: sourceName,
                pubDate: pubDate, link: link,
                audioURL: dict["audioURL"] as? String,
                duration: dict["duration"] as? TimeInterval,
                episodeNumber: nil,
                coverImageURL: dict["coverImageURL"] as? String,
                description: dict["description"] as? String
            ))
        case .video:
            return .video(VideoItem(
                id: id, title: title, sourceId: sourceId, sourceName: sourceName,
                pubDate: pubDate, link: link,
                videoURL: dict["videoURL"] as? String,
                thumbnailURL: dict["thumbnailURL"] as? String,
                duration: dict["duration"] as? TimeInterval,
                viewCount: nil,
                channelName: dict["channelName"] as? String,
                description: nil
            ))
        case .twitter:
            return .tweet(TweetItem(
                id: id, title: title, sourceId: sourceId, sourceName: sourceName,
                pubDate: pubDate, link: link,
                content: dict["content"] as? String ?? "",
                authorName: dict["authorName"] as? String ?? sourceName,
                authorHandle: dict["authorHandle"] as? String ?? "",
                authorAvatarURL: nil,
                mediaURLs: nil,
                likeCount: nil, retweetCount: nil, replyCount: nil
            ))
        }
    }
}

#Preview {
    SubscriptionScreen()
        .environmentObject(AudioPlayerManager())
}
