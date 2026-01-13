import SwiftUI

struct TweetItemRow: View {
    let item: TweetItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 10) {
                // Avatar
                avatarView
                
                // Author info
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.authorHandle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Date
                Text(item.displayDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            // Content
            Text(item.content)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // Media (if any)
            if let mediaURLs = item.mediaURLs, !mediaURLs.isEmpty {
                mediaGrid(mediaURLs)
            }
            
            // Stats (display only, no interaction)
            HStack(spacing: 20) {
                if let replyText = item.replyText {
                    statItem(icon: "bubble.left", text: replyText)
                }
                if let retweetText = item.retweetText {
                    statItem(icon: "arrow.2.squarepath", text: retweetText)
                }
                if let likeText = item.likeText {
                    statItem(icon: "heart", text: likeText)
                }
                Spacer()
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Components
    
    private var avatarView: some View {
        Group {
            if let avatarURL = item.authorAvatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        avatarPlaceholder
                    @unknown default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }
    
    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color.cyan.opacity(0.2))
            Text(String(item.authorName.prefix(1)))
                .font(.headline)
                .foregroundStyle(.cyan)
        }
    }
    
    private func statItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private func mediaGrid(_ urls: [String]) -> some View {
        let validURLs = urls.compactMap { URL(string: $0) }
        
        if validURLs.count == 1 {
            singleMediaView(validURLs[0])
        } else if validURLs.count == 2 {
            HStack(spacing: 4) {
                mediaImageView(validURLs[0])
                mediaImageView(validURLs[1])
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if validURLs.count == 3 {
            HStack(spacing: 4) {
                mediaImageView(validURLs[0])
                VStack(spacing: 4) {
                    mediaImageView(validURLs[1])
                    mediaImageView(validURLs[2])
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if validURLs.count >= 4 {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    mediaImageView(validURLs[0])
                    mediaImageView(validURLs[1])
                }
                HStack(spacing: 4) {
                    mediaImageView(validURLs[2])
                    mediaImageView(validURLs[3])
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func singleMediaView(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure, .empty:
                Rectangle()
                    .fill(Color(.systemGray5))
            @unknown default:
                Rectangle()
                    .fill(Color(.systemGray5))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func mediaImageView(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure, .empty:
                Rectangle()
                    .fill(Color(.systemGray5))
            @unknown default:
                Rectangle()
                    .fill(Color(.systemGray5))
            }
        }
    }
}

#Preview {
    List {
        TweetItemRow(item: TweetItem(
            id: "1",
            title: "Tweet",
            sourceId: "elonmusk",
            sourceName: "Elon Musk",
            pubDate: Date().addingTimeInterval(-1800),
            link: "https://twitter.com/elonmusk/status/xxx",
            content: "Just deployed the latest update to xAI's Grok. The improvements in reasoning are remarkable. Can't wait to share more details soon! 🚀",
            authorName: "Elon Musk",
            authorHandle: "@elonmusk",
            authorAvatarURL: nil,
            mediaURLs: ["https://picsum.photos/400/300"],
            likeCount: 58000,
            retweetCount: 12000,
            replyCount: 4500
        ))
    }
    .listStyle(.plain)
}
