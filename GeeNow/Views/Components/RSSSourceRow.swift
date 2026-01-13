import SwiftUI

struct RSSSourceRow: View {
    let source: RSSSource
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    private var isSubscribed: Bool {
        subscriptionManager.isSubscribed(source)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            sourceIcon
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(source.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    // Language badge
                    Text(source.language.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(languageColor.opacity(0.15))
                        .foregroundStyle(languageColor)
                        .clipShape(Capsule())
                }
                
                // Type indicator
                HStack(spacing: 4) {
                    Image(systemName: source.type.icon)
                        .font(.caption2)
                    Text(source.type.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Subscribe button
            subscribeButton
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Components
    
    private var sourceIcon: some View {
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
                    .foregroundStyle(typeColor)
            }
        }
    }
    
    private var subscribeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                subscriptionManager.toggleSubscription(source)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isSubscribed ? "checkmark" : "plus")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(isSubscribed ? "已订阅" : "订阅")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSubscribed ? Color(.systemGray5) : Color.accentColor)
            .foregroundColor(isSubscribed ? .secondary : .white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Colors
    
    private var typeColor: Color {
        switch source.type {
        case .article: return .blue
        case .podcast: return .purple
        case .video: return .red
        case .twitter: return .cyan
        }
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
    List {
        RSSSourceRow(source: RSSSource(
            id: "test",
            name: "机器之心",
            feedURL: "https://example.com/feed",
            type: .article,
            category: .ai,
            language: .chinese,
            icon: "🤖"
        ))
        
        RSSSourceRow(source: RSSSource(
            id: "test2",
            name: "Lex Fridman Podcast",
            feedURL: "https://example.com/feed",
            type: .podcast,
            category: .techPodcast,
            language: .english
        ))
    }
}
