import Testing
@testable import IceMacOS27Core

@Suite("PermissionsOnboarding27")
struct PermissionsOnboarding27Tests {
    @Test("Onboarding interrupted before Continue reopens at the next launch")
    func interruptedReopens() {
        #expect(PermissionsOnboarding27.shouldReopen(hasRequired: true, hasAll: false, completed: false))
    }

    @Test("Once Continue was clicked, a missing optional permission never reopens the window")
    func completedNeverReopens() {
        #expect(!PermissionsOnboarding27.shouldReopen(hasRequired: true, hasAll: false, completed: true))
    }

    @Test("Nothing left to grant never reopens the window")
    func allGrantedNeverReopens() {
        #expect(!PermissionsOnboarding27.shouldReopen(hasRequired: true, hasAll: true, completed: false))
    }

    @Test("A missing required permission is the existing path, not this rule")
    func missingRequiredIsNotThisRule() {
        #expect(!PermissionsOnboarding27.shouldReopen(hasRequired: false, hasAll: false, completed: false))
    }
}
