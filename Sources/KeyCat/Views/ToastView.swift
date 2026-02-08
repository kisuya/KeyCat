import SwiftUI

struct ToastMessage: Equatable {
    let text: String
    let icon: String

    static func copied(_ text: String = "복사됨") -> ToastMessage {
        ToastMessage(text: text, icon: "checkmark.circle.fill")
    }

    static func reloaded() -> ToastMessage {
        ToastMessage(text: "리로드됨", icon: "arrow.clockwise")
    }

    static func error(_ text: String) -> ToastMessage {
        ToastMessage(text: text, icon: "exclamationmark.triangle.fill")
    }
}

struct ToastOverlay: ViewModifier {
    let message: ToastMessage?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let message {
                HStack(spacing: 6) {
                    Image(systemName: message.icon)
                        .font(.caption)
                    Text(message.text)
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThickMaterial)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: message)
    }
}

extension View {
    func toast(_ message: ToastMessage?) -> some View {
        modifier(ToastOverlay(message: message))
    }
}
