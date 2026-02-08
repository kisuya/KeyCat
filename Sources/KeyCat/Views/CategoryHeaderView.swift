import SwiftUI

struct CategoryHeaderView: View {
    let name: String
    var shortcutCount: Int = 0
    var isCollapsed: Bool = false
    var onToggle: (() -> Void)? = nil

    var body: some View {
        Button {
            onToggle?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(width: 10)

                Text(name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if shortcutCount > 0 {
                    Text("\(shortcutCount)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(.quaternary)
                        )
                }

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.background)
    }
}
