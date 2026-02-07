import Testing
@testable import KeyCat

@Suite("KeyFormatter Tests")
struct KeyFormatterTests {

    @Test("Converts Ctrl+ to control symbol")
    func ctrlSymbol() {
        #expect(KeyFormatter.format("Ctrl+a") == "\u{2303}a")
        #expect(KeyFormatter.format("ctrl+c") == "\u{2303}c")
    }

    @Test("Converts Shift+ to shift symbol")
    func shiftSymbol() {
        #expect(KeyFormatter.format("Shift+g") == "\u{21E7}g")
    }

    @Test("Converts Alt/Option to option symbol")
    func altSymbol() {
        #expect(KeyFormatter.format("Alt+x") == "\u{2325}x")
        #expect(KeyFormatter.format("Option+x") == "\u{2325}x")
    }

    @Test("Converts Cmd/Command to command symbol")
    func cmdSymbol() {
        #expect(KeyFormatter.format("Cmd+s") == "\u{2318}s")
        #expect(KeyFormatter.format("Command+q") == "\u{2318}q")
    }

    @Test("Converts special keys")
    func specialKeys() {
        #expect(KeyFormatter.format("Enter") == "\u{21A9}")
        #expect(KeyFormatter.format("Tab") == "\u{21E5}")
        #expect(KeyFormatter.format("Space") == "\u{2423}")
        #expect(KeyFormatter.format("Escape") == "\u{238B}")
        #expect(KeyFormatter.format("Backspace") == "\u{232B}")
    }

    @Test("Handles combined modifiers")
    func combinedModifiers() {
        let result = KeyFormatter.format("Ctrl+Shift+p")
        #expect(result == "\u{2303}\u{21E7}p")
    }

    @Test("Preserves text without known modifiers")
    func noModifiers() {
        #expect(KeyFormatter.format("gg") == "gg")
        #expect(KeyFormatter.format("dd") == "dd")
    }
}
