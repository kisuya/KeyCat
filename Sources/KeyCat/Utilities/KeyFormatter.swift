import Foundation

enum KeyFormatter {
    private static let symbolMap: [(String, String)] = [
        ("Ctrl+", "\u{2303}"),
        ("ctrl+", "\u{2303}"),
        ("Control+", "\u{2303}"),
        ("control+", "\u{2303}"),
        ("Shift+", "\u{21E7}"),
        ("shift+", "\u{21E7}"),
        ("Alt+", "\u{2325}"),
        ("alt+", "\u{2325}"),
        ("Option+", "\u{2325}"),
        ("option+", "\u{2325}"),
        ("Opt+", "\u{2325}"),
        ("opt+", "\u{2325}"),
        ("Cmd+", "\u{2318}"),
        ("cmd+", "\u{2318}"),
        ("Command+", "\u{2318}"),
        ("command+", "\u{2318}"),
        ("Super+", "\u{2318}"),
        ("super+", "\u{2318}"),
        ("Enter", "\u{21A9}"),
        ("enter", "\u{21A9}"),
        ("Return", "\u{21A9}"),
        ("return", "\u{21A9}"),
        ("Tab", "\u{21E5}"),
        ("tab", "\u{21E5}"),
        ("Space", "\u{2423}"),
        ("space", "\u{2423}"),
        ("Escape", "\u{238B}"),
        ("escape", "\u{238B}"),
        ("Esc", "\u{238B}"),
        ("esc", "\u{238B}"),
        ("Backspace", "\u{232B}"),
        ("backspace", "\u{232B}"),
        ("Delete", "\u{2326}"),
        ("delete", "\u{2326}"),
    ]

    static func format(_ raw: String) -> String {
        var result = raw
        for (text, symbol) in symbolMap {
            result = result.replacingOccurrences(of: text, with: symbol)
        }
        return result
    }
}
