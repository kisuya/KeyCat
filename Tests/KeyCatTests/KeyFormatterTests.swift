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

    @Test("Backspace does not conflict with Space")
    func backspaceNoConflict() {
        #expect(KeyFormatter.format("Backspace") == "\u{232B}")
        #expect(KeyFormatter.format("Space") == "\u{2423}")
        #expect(KeyFormatter.format("Ctrl+Backspace") == "\u{2303}\u{232B}")
    }

    @Test("Escape does not conflict with Esc")
    func escapeEscNoConflict() {
        #expect(KeyFormatter.format("Escape") == "\u{238B}")
        #expect(KeyFormatter.format("Esc") == "\u{238B}")
    }

    @Test("Case variants of modifiers")
    func caseVariants() {
        #expect(KeyFormatter.format("ctrl+x") == "\u{2303}x")
        #expect(KeyFormatter.format("shift+a") == "\u{21E7}a")
        #expect(KeyFormatter.format("cmd+z") == "\u{2318}z")
        #expect(KeyFormatter.format("alt+f") == "\u{2325}f")
    }

    @Test("Delete key")
    func deleteKey() {
        #expect(KeyFormatter.format("Delete") == "\u{2326}")
        #expect(KeyFormatter.format("delete") == "\u{2326}")
    }

    @Test("Return is alias for Enter")
    func returnAlias() {
        #expect(KeyFormatter.format("Return") == "\u{21A9}")
        #expect(KeyFormatter.format("return") == "\u{21A9}")
    }

    @Test("Super+ maps to Command symbol")
    func superModifier() {
        #expect(KeyFormatter.format("Super+a") == "\u{2318}a")
    }

    @Test("Opt+ maps to Option symbol")
    func optModifier() {
        #expect(KeyFormatter.format("Opt+v") == "\u{2325}v")
    }

    @Test("Empty string returns empty")
    func emptyString() {
        #expect(KeyFormatter.format("") == "")
    }

    @Test("Triple modifier combination")
    func tripleModifier() {
        let result = KeyFormatter.format("Ctrl+Shift+Alt+x")
        #expect(result == "\u{2303}\u{21E7}\u{2325}x")
    }
}
