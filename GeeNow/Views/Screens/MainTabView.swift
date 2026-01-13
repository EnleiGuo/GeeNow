import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var audioPlayer: AudioPlayerManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .tabItem {
                        Label("热榜", systemImage: "flame.fill")
                    }
                    .tag(0)
                
                SubscriptionScreen()
                    .tabItem {
                        Label("订阅", systemImage: "plus.rectangle.on.folder.fill")
                    }
                    .tag(1)
                
                ReadingScreen()
                    .tabItem {
                        Label("阅读", systemImage: "book.fill")
                    }
                    .tag(2)
            }
            .tint(.orange)
            
            // Mini audio player (shows above tab bar when playing)
            VStack(spacing: 0) {
                AudioPlayerView()
                    .offset(y: -49) // Tab bar height
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AudioPlayerManager())
}
