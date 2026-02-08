import Testing
@testable import KeyCat

@Suite("ToastMessage Tests")
struct ToastMessageTests {

    @Test("Copied convenience constructor uses default text")
    func copiedDefault() {
        let toast = ToastMessage.copied()
        #expect(toast.text == "복사됨")
        #expect(toast.icon == "checkmark.circle.fill")
    }

    @Test("Copied convenience constructor uses custom text")
    func copiedCustom() {
        let toast = ToastMessage.copied("키 복사됨")
        #expect(toast.text == "키 복사됨")
    }

    @Test("Reloaded convenience constructor")
    func reloaded() {
        let toast = ToastMessage.reloaded()
        #expect(toast.text == "리로드됨")
        #expect(toast.icon == "arrow.clockwise")
    }

    @Test("Error convenience constructor")
    func error() {
        let toast = ToastMessage.error("파일 오류")
        #expect(toast.text == "파일 오류")
        #expect(toast.icon == "exclamationmark.triangle.fill")
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = ToastMessage.copied()
        let b = ToastMessage.copied()
        let c = ToastMessage.reloaded()
        #expect(a == b)
        #expect(a != c)
    }
}
