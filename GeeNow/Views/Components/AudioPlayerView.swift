import SwiftUI

struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerManager
    @State private var showExpandedPlayer = false
    
    var body: some View {
        if let item = audioPlayer.currentItem {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Cover
                    coverImage(item)
                    
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text(item.sourceName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 16) {
                        // Play/Pause
                        Button {
                            if audioPlayer.isPlaying {
                                audioPlayer.pause()
                            } else {
                                audioPlayer.resume()
                            }
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundStyle(.purple)
                        }
                        
                        // Close
                        Button {
                            audioPlayer.stop()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .contentShape(Rectangle())
                .onTapGesture {
                    showExpandedPlayer = true
                }
                
                // Progress bar
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: geometry.size.width * audioPlayer.progress)
                }
                .frame(height: 2)
                .background(Color(.systemGray5))
            }
            .sheet(isPresented: $showExpandedPlayer) {
                ExpandedAudioPlayerView()
            }
        }
    }
    
    private func coverImage(_ item: PodcastItem) -> some View {
        Group {
            if let coverURL = item.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        coverPlaceholder
                    }
                }
            } else {
                coverPlaceholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var coverPlaceholder: some View {
        ZStack {
            Color.purple.opacity(0.2)
            Image(systemName: "mic.fill")
                .foregroundStyle(.purple)
        }
    }
}

// MARK: - Expanded Player

struct ExpandedAudioPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Cover
                if let item = audioPlayer.currentItem {
                    coverImage(item)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(item.sourceName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Progress
                VStack(spacing: 8) {
                    // Slider
                    Slider(
                        value: Binding(
                            get: { audioPlayer.currentTime },
                            set: { audioPlayer.seek(to: $0) }
                        ),
                        in: 0...max(audioPlayer.duration, 1)
                    )
                    .tint(.purple)
                    
                    // Time labels
                    HStack {
                        Text(audioPlayer.currentTimeText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("-\(audioPlayer.remainingTimeText)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                
                // Controls
                HStack(spacing: 40) {
                    // Skip backward
                    Button {
                        audioPlayer.skipBackward()
                    } label: {
                        Image(systemName: "gobackward.15")
                            .font(.title)
                            .foregroundStyle(.primary)
                    }
                    
                    // Play/Pause
                    Button {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            audioPlayer.resume()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 70, height: 70)
                            
                            if audioPlayer.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .offset(x: audioPlayer.isPlaying ? 0 : 2)
                            }
                        }
                    }
                    
                    // Skip forward
                    Button {
                        audioPlayer.skipForward()
                    } label: {
                        Image(systemName: "goforward.15")
                            .font(.title)
                            .foregroundStyle(.primary)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private func coverImage(_ item: PodcastItem) -> some View {
        Group {
            if let coverURL = item.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        coverPlaceholder
                    }
                }
            } else {
                coverPlaceholder
            }
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private var coverPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.5), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AudioPlayerView()
    }
    .environmentObject(AudioPlayerManager())
}
