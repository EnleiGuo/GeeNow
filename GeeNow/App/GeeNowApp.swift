//
//  GeeNowApp.swift
//  GeeNow
//
//  Created by Enlei Guo on 2026/1/12.
//

import SwiftUI

@main
struct GeeNowApp: App {
    @State private var showSplash = true
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showSplash ? 0 : 1)
                    .environmentObject(audioPlayer)
                
                if showSplash {
                    SplashScreen()
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashScreen: View {
    @State private var animate = false
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 1 : 0)
                    .symbolEffect(.pulse.byLayer, options: .repeating, value: animate)
                
                VStack(spacing: 8) {
                    Text("GeeNow")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    Text("实时热点新闻阅读器")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}
