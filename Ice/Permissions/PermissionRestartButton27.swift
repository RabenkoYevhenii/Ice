//
//  PermissionRestartButton27.swift
//  Ice
//

import OSLog
import SwiftUI

/// Shows "Restart Ice" in place of the Continue button while a permission waits for a restart.
///
/// Screen Recording reads as granted only once Ice has started again, and macOS's own offer to
/// quit and reopen does not reopen a self-built Ice (measured 2026-11-26): the window said
/// "Continue in Limited Mode" with every permission granted. Onboarding is not marked finished by
/// the restart, so the window comes back afterwards, with the permission granted.
@available(macOS 27.0, *)
struct PermissionRestartButton27<Fallback: View>: View {
    @ObservedObject var permission: Permission
    @ViewBuilder let fallback: () -> Fallback

    var body: some View {
        if PermissionsOnboarding27.shouldOfferRestart(
            requestedThisRun: permission.takesEffectAfterRestart && permission.wasRequested,
            granted: permission.hasPermission
        ) {
            Button {
                Self.relaunch()
            } label: {
                Text("Restart Ice to Apply \(permission.title)")
                    .frame(maxWidth: .infinity)
            }
        } else {
            fallback()
        }
    }

    /// Quits Ice and opens it again, once this instance has gone (see ``SelfRelaunch27``).
    private static func relaunch() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = SelfRelaunch27.arguments(bundlePath: Bundle.main.bundleURL.path, opener: "/usr/bin/open")
        do {
            try process.run()
        } catch {
            // Without the helper nothing would open Ice again, so Ice stays running.
            Logger(category: "Permissions").error("Could not start the restart helper: \(error, privacy: .public)")
            return
        }
        NSApp.terminate(nil)
    }
}
