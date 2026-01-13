import SwiftUI

struct PodcastItemRow: View {
    let item: PodcastItem
    @EnvironmentObject var audioPlayer: AudioPlayerManager
    
    private var isPlaying: Bool {
        audioPlayer.currentItem?.id == item.id && audioPlayer.isPlaying
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Cover image
            coverImage
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                // Source
                HStack(spacing: 6) {
                    Text(item.sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let episodeText = item.episodeText {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(episodeText)
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                    
                    Spacer()
                    
                    Text(item.displayDate)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                // Title
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                
                // Duration
                if let durationText = item.durationText {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(durationText)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            // Play button
            playButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Components
    
    private var coverImage: some View {
        Group {
            if let coverURL = item.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        coverPlaceholder
                    @unknown default:
                        coverPlaceholder
                    }
                }
            } else {
                coverPlaceholder
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            if isPlaying {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.purple, lineWidth: 2)
            }
        }
    }
    
    private var coverPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.3), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "mic.fill")
                .font(.title2)
                .foregroundStyle(.purple)
        }
    }
    
    private var playButton: some View {
        Button {
            if isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.play(item)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 44, height: 44)
                
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(x: isPlaying ? 0 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(item.audioURL == nil)
        .opacity(item.audioURL == nil ? 0.5 : 1)
    }
}

#Preview {
    List {
        PodcastItemRow(item: PodcastItem(
            id: "1",
            title: "与 Sam Altman 对话：AI 的未来走向",
            sourceId: "guigu101",
            sourceName: "硅谷101",
            pubDate: Date().addingTimeInterval(-7200),
            link: "https://example.com",
            audioURL: "https://example.com/audio.mp3",
            duration: 3720,
            episodeNumber: 156,
            coverImageURL: "https://picsum.photos/200",
            description: "本期节目我们邀请到了 OpenAI CEO Sam Altman..."
        ))
    }
    .listStyle(.plain)
    .environmentObject(AudioPlayerManager())
}
