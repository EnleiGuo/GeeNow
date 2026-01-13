import SwiftUI

// MARK: - List Layout Component
struct NewsSection: View {
    let source: Source
    let items: [NewsItem]
    let isLoading: Bool
    let isFavorite: Bool
    let onRefresh: () -> Void
    let onSourceTap: () -> Void
    let onToggleFavorite: () -> Void
    let onItemTap: (NewsItem) -> Void
    
    @State private var showAll = false
    private let initialCount = 10
    
    var displayItems: [NewsItem] {
        showAll ? Array(items.prefix(30)) : Array(items.prefix(initialCount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            
            if items.isEmpty && isLoading {
                LoadingPlaceholder()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                        CompactNewsRow(
                            item: item,
                            index: index + 1,
                            sourceColor: source.color,
                            showDivider: index < displayItems.count - 1,
                            onTap: { onItemTap(item) }
                        )
                    }
                    
                    if items.count > initialCount {
                        expandButton
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var sectionHeader: some View {
        HStack(spacing: 10) {
            Button(action: onSourceTap) {
                HStack(spacing: 8) {
                    SourceIcon(sourceId: source.id, color: source.color)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(source.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            if let title = source.title {
                                Text(title)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(source.color)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(source.color.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        Text("\(items.count) 条热点")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            FavoriteButton(isFavorite: isFavorite, color: source.color, action: onToggleFavorite)
            
            RefreshButton(isLoading: isLoading, color: source.color, action: onRefresh)
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

// MARK: - Card Layout Component
struct NewsCardView: View {
    let source: Source
    let items: [NewsItem]
    let isLoading: Bool
    let isFavorite: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let onRefresh: () -> Void
    let onSourceTap: () -> Void
    let onToggleFavorite: () -> Void
    let onItemTap: (NewsItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if items.isEmpty && isLoading {
                        LoadingPlaceholder()
                    } else {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            CompactNewsRow(
                                item: item,
                                index: index + 1,
                                sourceColor: source.color,
                                showDivider: index < items.count - 1,
                                onTap: { onItemTap(item) }
                            )
                        }
                    }
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(source.color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    private var cardHeader: some View {
        HStack(spacing: 10) {
            Button(action: onSourceTap) {
                HStack(spacing: 8) {
                    SourceIcon(sourceId: source.id, color: source.color)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(source.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            if let title = source.title {
                                Text(title)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(source.color)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(source.color.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        Text("\(items.count) 条热点")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            FavoriteButton(isFavorite: isFavorite, color: source.color, action: onToggleFavorite)
            
            RefreshButton(isLoading: isLoading, color: source.color, action: onRefresh)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(source.color.opacity(0.06))
    }
}

// MARK: - Compact News Row
struct CompactNewsRow: View {
    let item: NewsItem
    let index: Int
    let sourceColor: Color
    let showDivider: Bool
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap?()
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
                        
                        if let info = item.extra?.info {
                            Text(info)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer(minLength: 4)
                    
                    if let icon = item.extra?.icon {
                        BadgeIcon(name: icon)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(NewsRowButtonStyle())
            
            if showDivider {
                Divider().padding(.leading, 44)
            }
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
}

// MARK: - Supporting Views
private struct BadgeIcon: View {
    let name: String
    
    var body: some View {
        Group {
            switch name {
            case "hot":
                Image(systemName: "flame.fill").foregroundColor(.red)
            case "new":
                Image(systemName: "sparkles").foregroundColor(.orange)
            case "boom":
                Image(systemName: "bolt.fill").foregroundColor(.purple)
            default:
                EmptyView()
            }
        }
        .font(.system(size: 12))
    }
}

struct SourceIcon: View {
    let sourceId: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
            Text(String(sourceId.prefix(1)).uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .frame(width: 28, height: 28)
    }
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let color: Color
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFavorite ? .yellow : color.opacity(0.6))
                .scaleEffect(scale)
        }
    }
}

struct RefreshButton: View {
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

struct LoadingPlaceholder: View {
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
        .shimmering()
    }
}

// MARK: - Button Style for News Row
private struct NewsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
