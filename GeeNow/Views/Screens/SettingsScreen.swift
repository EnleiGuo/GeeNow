import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("refreshInterval") private var refreshInterval: Double = 600
    @AppStorage("enableNotifications") private var enableNotifications = false
    @State private var appIconBounce = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 32)
                            .symbolEffect(.pulse.byLayer, options: .repeating, value: appIconBounce)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GeeNow")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("实时热点新闻阅读器")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("v1.0.0")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(.accentColor)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    ForEach(Array(NewsService.shared.allSources.enumerated()), id: \.element.id) { index, source in
                        SourceRow(source: source, index: index)
                    }
                } header: {
                    Label("数据源", systemImage: "newspaper")
                }
                
                Section {
                    Picker(selection: $refreshInterval) {
                        Text("5分钟").tag(300.0)
                        Text("10分钟").tag(600.0)
                        Text("30分钟").tag(1800.0)
                        Text("1小时").tag(3600.0)
                    } label: {
                        Label("自动刷新间隔", systemImage: "clock.arrow.circlepath")
                    }
                    .sensoryFeedback(.selection, trigger: refreshInterval)
                } header: {
                    Label("刷新设置", systemImage: "gearshape")
                }
                
                Section {
                    NavigationLink {
                        DebugScreen()
                    } label: {
                        Label {
                            Text("源调试")
                        } icon: {
                            Image(systemName: "ladybug.fill")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Label("开发者", systemImage: "hammer")
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/example/geenow")!) {
                        Label {
                            Text("GitHub")
                        } icon: {
                            Image(systemName: "link")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label {
                            Text("隐私政策")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                } header: {
                    Label("关于", systemImage: "info.circle")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .onAppear {
                appIconBounce = true
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}

private struct SourceRow: View {
    let source: Source
    let index: Int
    
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(source.color.gradient)
                .frame(width: 12, height: 12)
                .shadow(color: source.color.opacity(0.5), radius: 4)
            
            Text(source.name)
                .fontWeight(.medium)
            
            Spacer()
            
            if let title = source.title {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
