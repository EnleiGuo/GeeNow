import SwiftUI
import AVKit
import SafariServices

struct VideoPlayerView: View {
    let item: VideoItem
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            if isYouTubeURL(item.link) || isYouTubeURL(item.videoURL ?? "") {
                YouTubeThumbnailView(item: item, videoId: youtubeVideoId)
            } else if let videoURL = extractDirectVideoURL() {
                VideoPlayer(player: player)
                    .onAppear {
                        player = AVPlayer(url: videoURL)
                    }
                    .onDisappear {
                        player?.pause()
                    }
            } else {
                fallbackThumbnail
            }
        }
    }
    
    private var fallbackThumbnail: some View {
        ZStack {
            if let thumbnailURL = item.thumbnailURL, let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(Color(.systemGray5))
                    }
                }
            } else {
                Rectangle().fill(Color(.systemGray5))
            }
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)
                .shadow(radius: 10)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: item.link) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private var youtubeVideoId: String? {
        extractYouTubeId(from: item.link) ?? extractYouTubeId(from: item.videoURL ?? "")
    }
    
    private func extractDirectVideoURL() -> URL? {
        if let videoURL = item.videoURL, !isYouTubeURL(videoURL), let url = URL(string: videoURL) {
            return url
        }
        if !isYouTubeURL(item.link), let url = URL(string: item.link) {
            return url
        }
        return nil
    }
    
    private func isYouTubeURL(_ url: String) -> Bool {
        url.contains("youtube.com") || url.contains("youtu.be")
    }
    
    private func extractYouTubeId(from url: String) -> String? {
        let patterns = [
            "youtube\\.com/watch\\?v=([a-zA-Z0-9_-]{11})",
            "youtu\\.be/([a-zA-Z0-9_-]{11})",
            "youtube\\.com/embed/([a-zA-Z0-9_-]{11})",
            "youtube\\.com/v/([a-zA-Z0-9_-]{11})"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }
}

struct YouTubeThumbnailView: View {
    let item: VideoItem
    let videoId: String?
    @State private var showSafari = false
    
    private var thumbnailURL: URL? {
        if let thumb = item.thumbnailURL, let url = URL(string: thumb) {
            return url
        }
        if let id = videoId {
            return URL(string: "https://img.youtube.com/vi/\(id)/maxresdefault.jpg")
        }
        return nil
    }
    
    private var youtubeWatchURL: URL? {
        if let id = videoId {
            return URL(string: "https://www.youtube.com/watch?v=\(id)")
        }
        return URL(string: item.link)
    }
    
    var body: some View {
        ZStack {
            if let url = thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        fallbackThumbnail
                    default:
                        Rectangle().fill(Color(.systemGray6))
                    }
                }
            } else {
                fallbackThumbnail
            }
            
            playButton
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSafari = true
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = youtubeWatchURL {
                SafariVideoPlayer(url: url)
            }
        }
    }
    
    private var fallbackThumbnail: some View {
        ZStack {
            Rectangle().fill(Color(.systemGray5))
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
        }
    }
    
    private var playButton: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.7))
                    .frame(width: 68, height: 68)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .offset(x: 2)
            }
            
            Text("点击播放")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.6))
                .clipShape(Capsule())
        }
    }
}

struct SafariVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = .systemRed
        safari.preferredBarTintColor = .black
        safari.delegate = context.coordinator
        
        let nav = UINavigationController(rootViewController: safari)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let dismissAction: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismissAction = dismiss
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismissAction()
        }
    }
}

#Preview {
    VideoPlayerView(item: VideoItem(
        id: "1",
        title: "Test Video",
        sourceId: "test",
        sourceName: "Test",
        pubDate: Date(),
        link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        videoURL: nil,
        thumbnailURL: nil,
        duration: 212,
        viewCount: 1000000,
        channelName: "Test Channel",
        description: nil
    ))
    .aspectRatio(16/9, contentMode: .fit)
}
