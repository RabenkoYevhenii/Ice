import Testing
@testable import IceMacOS27Core

@Suite("NativeWriteHealth27")
struct NativeWriteHealth27Tests {
    @Test("A single failed sync is retried, not a fallback")
    func oneFailureIsNotBlocked() {
        var health = NativeWriteHealth27()
        health.record(synchronized: false)
        #expect(!health.isBlocked)
    }

    @Test("Two failed syncs in a row block the native switch")
    func twoFailuresBlock() {
        var health = NativeWriteHealth27()
        health.record(synchronized: false)
        health.record(synchronized: false)
        #expect(health.isBlocked)
    }

    @Test("A successful sync unblocks and starts the count again")
    func successUnblocks() {
        var health = NativeWriteHealth27()
        health.record(synchronized: false)
        health.record(synchronized: false)
        health.record(synchronized: true)
        #expect(!health.isBlocked)
        health.record(synchronized: false)
        #expect(!health.isBlocked)
    }
}
