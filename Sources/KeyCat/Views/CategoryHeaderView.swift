import SwiftUI

struct CategoryHeaderView: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(.background)
    }
}
