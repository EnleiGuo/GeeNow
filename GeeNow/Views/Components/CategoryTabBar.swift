import SwiftUI

struct CategoryTabBar: View {
    @Binding var selectedCategory: Category
    let categories: [Category]
    @Namespace private var namespace
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(categories) { category in
                        CategoryTabItem(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            namespace: namespace
                        ) {
                            withAnimation(.snappy(duration: 0.3)) {
                                selectedCategory = category
                            }
                        }
                        .id(category)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: selectedCategory) { _, newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .overlay(
            Divider()
                .opacity(0.5),
            alignment: .bottom
        )
    }
}

private struct CategoryTabItem: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(Color.primary)
                        .matchedGeometryEffect(id: "bg", in: namespace)
                        .frame(height: 32)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 32)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(.systemBackground) : .secondary)
                    .padding(.horizontal, 16)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        VStack {
            CategoryTabBar(
                selectedCategory: .constant(.hottest),
                categories: Category.allCases
            )
            Spacer()
        }
    }
}
