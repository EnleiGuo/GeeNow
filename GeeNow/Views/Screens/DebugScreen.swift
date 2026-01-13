import SwiftUI

struct DebugScreen: View {
    @State private var results: [SourceTestResult] = []
    @State private var isLoading = false
    
    private let testSources: [(String, any NewsSourceProtocol)] = [
        ("财联社电报", ClsSource()),
        ("百度热搜", BaiduSource()),
        ("虎扑热帖", HupuSource()),
        ("36氪快讯", Kr36Source())
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: runTests) {
                        HStack {
                            Text("运行测试")
                            Spacer()
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading)
                }
                
                ForEach(results) { result in
                    Section(header: Text(result.name)) {
                        if let error = result.error {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("失败", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("错误类型: \(String(describing: type(of: error)))")
                                    .font(.caption)
                                Text("错误信息: \(error.localizedDescription)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let debugInfo = result.debugInfo {
                                    Text("调试信息: \(debugInfo)")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("成功 - \(result.itemCount) 条", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                if let firstTitle = result.firstItemTitle {
                                    Text("首条: \(firstTitle)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                if let debugInfo = result.debugInfo {
                                    Text("调试: \(debugInfo)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("源调试")
        }
    }
    
    private func runTests() {
        isLoading = true
        results = []
        
        Task {
            var newResults: [SourceTestResult] = []
            
            for (name, source) in testSources {
                let result = await testSource(name: name, source: source)
                newResults.append(result)
            }
            
            await MainActor.run {
                results = newResults
                isLoading = false
            }
        }
    }
    
    private func testSource(name: String, source: any NewsSourceProtocol) async -> SourceTestResult {
        do {
            let items = try await source.fetch()
            return SourceTestResult(
                name: name,
                itemCount: items.count,
                firstItemTitle: items.first?.title,
                error: nil,
                debugInfo: "ID: \(source.source.id)"
            )
        } catch {
            return SourceTestResult(
                name: name,
                itemCount: 0,
                firstItemTitle: nil,
                error: error,
                debugInfo: "Source ID: \(source.source.id)"
            )
        }
    }
}

struct SourceTestResult: Identifiable {
    let id = UUID()
    let name: String
    let itemCount: Int
    let firstItemTitle: String?
    let error: Error?
    let debugInfo: String?
}

#Preview {
    DebugScreen()
}
