import Foundation

struct YAMLLoadError: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let message: String

    static func == (lhs: YAMLLoadError, rhs: YAMLLoadError) -> Bool {
        lhs.fileName == rhs.fileName && lhs.message == rhs.message
    }
}
