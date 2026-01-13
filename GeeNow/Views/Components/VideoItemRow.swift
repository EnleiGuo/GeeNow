import SwiftUI

struct VideoItemRow: View {
    let item: VideoItem
    @State private var showPlayer = false
    
    var body: some View {
        Button {
            showPlayer = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Thumbnail
                thumbnailView
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)
                    
                    // Channel and stats
                    HStack(spacing: 6) {
                        if let channelName = item.channelName {
                            Text(channelName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let viewCountText = item.viewCountText {
                            Text("·")
                                .foregroundStyle(.tertiary)
                            HStack(spacing: 2) {
                                Image(systemName: "eye")
                                    .font(.caption2)
                                Text(viewCountText)
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.displayDate)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPlayer) {
            VideoPlayerSheet(item: item)
        }
    }
    
    // MARK: - Thumbnail
    
    private var thumbnailView: some View {
        ZStack(alignment: .bottomTrailing) {
            // Thumbnail image
            Group {
                if let thumbnailURL = item.thumbnailURL, let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        case .failure, .empty:
                            thumbnailPlaceholder
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                } else {
                    thumbnailPlaceholder
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Play button overlay
            ZStack {
                Circle()
                    .fill(.black.opacity(0.5))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Duration badge
            if let durationText = item.durationText {
                Text(durationText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.7))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(8)
            }
        }
    }
    
    private var thumbnailPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray5))
            Image(systemName: "play.rectangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
        }
        .aspectRatio(16/9, contentMode: .fill)
    }
}

// MARK: - Video Player Sheet

struct VideoPlayerSheet: View {
    let item: VideoItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Video Player
                VideoPlayerView(item: item)
                    .aspectRatio(16/9, contentMode: .fit)
                
                // Info
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 12) {
                            if let channelName = item.channelName {
                                Label(channelName, systemImage: "person.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let viewCountText = item.viewCountText {
                                Label("\(viewCountText) 次观看", systemImage: "eye")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if let description = item.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        VideoItemRow(item: VideoItem(
            id: "1",
            title: "10 分钟了解 GPT-5 的新功能",
            sourceId: "youtube-ai",
            sourceName: "AI Explained",
            pubDate: Date().addingTimeInterval(-86400),
            link: "https://youtube.com/watch?v=xxx",
            videoURL: "https://youtube.com/watch?v=xxx",
            thumbnailURL: "https://picsum.photos/640/360",
            duration: 620,
            viewCount: 125000,
            channelName: "AI Explained",
            description: "本期视频我们将深入了解 GPT-5 带来的革命性变化..."
        ))
    }
    .listStyle(.plain)
}
