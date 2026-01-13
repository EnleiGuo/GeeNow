import SwiftUI
import UIKit

struct FilterTabBar<T: Hashable>: View {
    @Binding var selection: T
    let items: [T]
    let titleProvider: (T) -> String
    @Namespace private var namespace
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(items, id: \.self) { item in
                        FilterTabItem(
                            title: titleProvider(item),
                            isSelected: selection == item,
                            namespace: namespace
                        ) {
                            withAnimation(.snappy(duration: 0.3)) {
                                selection = item
                            }
                        }
                        .id(item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: selection) { _, newValue in
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

private struct FilterTabItem: View {
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
                        .matchedGeometryEffect(id: "filter_bg", in: namespace)
                        .frame(height: 32)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 32)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : .secondary)
                    .padding(.horizontal, 16)
            }
        }
        .buttonStyle(FilterScaleButtonStyle())
    }
}

private struct FilterScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
