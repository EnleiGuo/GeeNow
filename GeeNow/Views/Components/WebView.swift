import SwiftUI
import WebKit

struct WebViewSheet: View {
    let url: URL
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var progress: Double = 0
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var webView: WKWebView?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                WebView(
                    url: url,
                    isLoading: $isLoading,
                    progress: $progress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    webView: $webView
                )
                .ignoresSafeArea(edges: .bottom)
                
                if isLoading {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            webView?.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!canGoBack)
                        
                        Button {
                            webView?.goForward()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!canGoForward)
                        
                        Button {
                            webView?.reload()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .presentationCornerRadius(20)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var progress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var webView: WKWebView?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        DispatchQueue.main.async {
            self.webView = webView
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        context.coordinator.observeProgress(webView)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        private var progressObservation: NSKeyValueObservation?
        private var canGoBackObservation: NSKeyValueObservation?
        private var canGoForwardObservation: NSKeyValueObservation?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func observeProgress(_ webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = webView.estimatedProgress
                }
            }
            
            canGoBackObservation = webView.observe(\.canGoBack) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoBack = webView.canGoBack
                }
            }
            
            canGoForwardObservation = webView.observe(\.canGoForward) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoForward = webView.canGoForward
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}
