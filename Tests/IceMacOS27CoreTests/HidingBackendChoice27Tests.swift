import Testing
@testable import IceMacOS27Core

@Suite("HidingBackendChoice27")
struct HidingBackendChoice27Tests {
    @Test("Native selected and readable uses native, no warning")
    func nativeWorks() {
        #expect(
            HidingBackendChoice27.decide(nativeSelected: true, nativeAvailable: true, nativeFailed: false)
                == .init(backend: .native, warnNativeUnavailable: false)
        )
    }

    @Test("Native selected but unreadable falls back to assessment and warns")
    func nativeUnavailableWarns() {
        #expect(
            HidingBackendChoice27.decide(nativeSelected: true, nativeAvailable: false, nativeFailed: false)
                == .init(backend: .assessment, warnNativeUnavailable: true)
        )
    }

    @Test("Native that failed while applying falls back to assessment and warns")
    func failedNativeWarns() {
        #expect(
            HidingBackendChoice27.decide(nativeSelected: true, nativeAvailable: true, nativeFailed: true)
                == .init(backend: .assessment, warnNativeUnavailable: true)
        )
    }

    @Test("Assessment chosen by the user is never a warning")
    func assessmentSelectedNoWarning() {
        let expected = HidingBackendChoice27.Decision(backend: .assessment, warnNativeUnavailable: false)
        for available in [false, true] {
            #expect(
                HidingBackendChoice27.decide(nativeSelected: false, nativeAvailable: available, nativeFailed: false)
                    == expected
            )
        }
    }
}
