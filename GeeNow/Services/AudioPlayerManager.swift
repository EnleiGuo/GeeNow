import Foundation
import AVFoundation
import Combine

@MainActor
class AudioPlayerManager: ObservableObject {
    @Published private(set) var currentItem: PodcastItem?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var playbackObserver: NSKeyValueObservation?
    
    init() {
        setupAudioSession()
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        statusObserver?.invalidate()
        playbackObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func play(_ item: PodcastItem) {
        guard let audioURLString = item.audioURL,
              let audioURL = URL(string: audioURLString) else {
            error = AudioPlayerError.invalidURL
            return
        }
        
        // If same item, just resume
        if currentItem?.id == item.id {
            resume()
            return
        }
        
        // Stop current playback
        stop()
        
        // Start new playback
        currentItem = item
        isLoading = true
        error = nil
        
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        
        setupObservers()
        
        player?.play()
        isPlaying = true
    }
    
    func resume() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        removeObservers()
        player?.pause()
        player = nil
        currentItem = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        isLoading = false
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func skipForward(_ seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(_ seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupObservers() {
        guard let player = player, let playerItem = player.currentItem else { return }
        
        // Time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }
        
        // Status observer
        statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.duration = item.duration.seconds.isNaN ? 0 : item.duration.seconds
                case .failed:
                    self?.isLoading = false
                    self?.error = item.error ?? AudioPlayerError.playbackFailed
                    self?.isPlaying = false
                default:
                    break
                }
            }
        }
        
        // Playback finished observer
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.currentTime = 0
                self?.seek(to: 0)
            }
        }
    }
    
    private func removeObservers() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        statusObserver?.invalidate()
        statusObserver = nil
        playbackObserver?.invalidate()
        playbackObserver = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var currentTimeText: String {
        formatTime(currentTime)
    }
    
    var durationText: String {
        formatTime(duration)
    }
    
    var remainingTimeText: String {
        formatTime(duration - currentTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && time.isFinite else { return "0:00" }
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Error Types

enum AudioPlayerError: LocalizedError {
    case invalidURL
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的音频链接"
        case .playbackFailed:
            return "播放失败"
        }
    }
}
