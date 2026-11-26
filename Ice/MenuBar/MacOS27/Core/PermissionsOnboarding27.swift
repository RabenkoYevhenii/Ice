//
//  PermissionsOnboarding27.swift
//  Ice
//

/// Whether the permissions window reopens at launch on macOS 27.
///
/// The window used to reopen only while a required permission was missing. Granting Screen
/// Recording makes macOS offer to quit and reopen the app, and for a self-built Ice the reopen
/// never happens (measured 2026-11-26): the app quit mid-onboarding and, with everything required
/// granted, never showed the window again — so Full Disk Access, which native hiding needs, was
/// never reached. Onboarding now counts as finished only when the user clicks Continue.
enum PermissionsOnboarding27 {
    /// Whether to show the permissions window again although every required permission is granted.
    ///
    /// - Parameters:
    ///   - hasRequired: Whether every required permission is granted.
    ///   - hasAll: Whether every permission, optional ones included, is granted.
    ///   - completed: Whether the user has clicked Continue in the permissions window.
    static func shouldReopen(hasRequired: Bool, hasAll: Bool, completed: Bool) -> Bool {
        hasRequired && !hasAll && !completed
    }

    /// Whether to offer restarting Ice for a permission that only counts after a restart.
    ///
    /// Screen Recording reads as not granted until the app starts again, so the window used to say
    /// "Continue in Limited Mode" with everything granted — and macOS's own quit-and-reopen does
    /// not reopen a self-built Ice. Ice offers the restart itself instead.
    ///
    /// - Parameters:
    ///   - requestedThisRun: Whether the user asked for the permission since Ice started.
    ///   - granted: Whether the permission reads as granted now.
    static func shouldOfferRestart(requestedThisRun: Bool, granted: Bool) -> Bool {
        requestedThisRun && !granted
    }
}
