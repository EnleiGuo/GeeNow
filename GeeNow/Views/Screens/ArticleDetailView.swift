import SwiftUI

struct ArticleDetailView: View {
    let item: NewsItem
    let sourceColor: Color
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showWebView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    
                    Divider()
                        .padding(.vertical, 16)
                    
                    contentSection
                    
                    Spacer(minLength: 40)
                    
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
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
                            showWebView = true
                        } label: {
                            Image(systemName: "safari")
                                .font(.system(size: 16))
                        }
                        
                        if let url = URL(string: item.url) {
                            ShareLink(item: url) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                            }
                        }
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .sheet(isPresented: $showWebView) {
                if let url = URL(string: item.mobileUrl ?? item.url) {
                    WebViewSheet(url: url, title: item.title)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .presentationCornerRadius(20)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 8) {
                if let sourceName = item.sourceName {
                    Text(sourceName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(sourceColor)
                }
                
                if let author = item.author, !author.isEmpty {
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(author)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                if let date = item.pubDate {
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(formatDate(date))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let content = item.content, !content.isEmpty {
                Text(stripHTML(content))
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            } else if let hover = item.extra?.hover, !hover.isEmpty {
                Text(hover)
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            } else if let info = item.extra?.info, !info.isEmpty {
                Text(info)
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("点击下方按钮查看完整内容")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }
    
    private func stripHTML(_ html: String) -> String {
        var result = html
        result = result.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        result = result.replacingOccurrences(of: "</p>", with: "\n\n")
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var footerSection: some View {
        Button {
            showWebView = true
        } label: {
            HStack {
                Image(systemName: "safari")
                Text("查看原文")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(sourceColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "今天 " + formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "HH:mm"
            return "昨天 " + formatter.string(from: date)
        } else {
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }
}
