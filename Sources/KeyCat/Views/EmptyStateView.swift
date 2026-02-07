import SwiftUI

struct EmptyStateView: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)

            if query.isEmpty {
                Text("단축키가 없습니다")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Text("'\(query)' 검색 결과 없음")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("다른 검색어를 시도해 보세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
