//
//  HidingBackendChoice27.swift
//  Ice
//

/// Which hiding backend is in force on macOS 27, and whether the user must be told.
///
/// The native switch needs Full Disk Access: without it, MenuBarAgent's list in the
/// `group.com.apple.controlcenter` container cannot be read (measured 2026-11-26: tccd checks
/// Full Disk Access, then refuses the narrower app-data consent without asking), and Ice falls
/// back to assessment mode. That fallback used to be silent — Settings still said "native" while
/// every click on a system item flashed the hidden items — so a fallback the user did not choose
/// is always reported.
enum HidingBackendChoice27 {
    enum Backend: Equatable {
        case native
        case assessment
    }

    struct Decision: Equatable {
        /// The backend to apply.
        let backend: Backend

        /// Whether the user picked the native switch but it is not in force.
        let warnNativeUnavailable: Bool
    }

    /// The backend for the user's choice and what this system allows.
    ///
    /// - Parameters:
    ///   - nativeSelected: Whether the user chose the native switch.
    ///   - nativeAvailable: Whether MenuBarAgent's list can be read right now.
    ///   - nativeFailed: Whether applying through the native switch has failed since launch.
    static func decide(nativeSelected: Bool, nativeAvailable: Bool, nativeFailed: Bool) -> Decision {
        guard nativeSelected else {
            return Decision(backend: .assessment, warnNativeUnavailable: false)
        }
        guard nativeAvailable, !nativeFailed else {
            return Decision(backend: .assessment, warnNativeUnavailable: true)
        }
        return Decision(backend: .native, warnNativeUnavailable: false)
    }
}
