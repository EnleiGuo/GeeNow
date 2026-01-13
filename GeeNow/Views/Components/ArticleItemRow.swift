import SwiftUI

struct ArticleItemRow: View {
    let item: ArticleItem
    @State private var showWebView = false
    
    var body: some View {
        Button {
            showWebView = true
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    // Source and date
                    HStack(spacing: 6) {
                        Text(item.sourceName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let author = item.author {
                            Text("·")
                                .foregroundStyle(.tertiary)
                            Text(author)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
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
                    
                    // Summary
                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Score badge
                    if let scoreText = item.scoreText {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(scoreText)
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                    }
                }
                
                // Thumbnail
                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            thumbnailPlaceholder
                        case .empty:
                            thumbnailPlaceholder
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showWebView) {
            if let url = URL(string: item.link) {
                SafariView(url: url)
            }
        }
    }
    
    private var thumbnailPlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "doc.text")
                    .foregroundStyle(.tertiary)
            }
    }
}

#Preview {
    List {
        ArticleItemRow(item: ArticleItem(
            id: "1",
            title: "OpenAI 发布 GPT-5，性能大幅提升",
            sourceId: "jiqizhixin",
            sourceName: "机器之心",
            pubDate: Date().addingTimeInterval(-3600),
            link: "https://example.com",
            summary: "OpenAI 今日正式发布了 GPT-5 模型，在推理能力、多模态处理等方面都有显著提升...",
            content: nil,
            imageURL: "https://picsum.photos/200",
            author: "张三",
            score: 95
        ))
    }
    .listStyle(.plain)
}
