//
//  NativeWriteHealth27.swift
//  Ice
//

/// Whether writes through the native switch still reach MenuBarAgent.
///
/// When Full Disk Access is taken away while Ice runs, reading MenuBarAgent's list keeps working
/// but every write fails to synchronize (measured 2026-11-26), and a failed sync was only ever
/// retried at the next change — so the chevron did nothing, and nothing said why. One failed sync
/// can be a passing hiccup and is still retried; two in a row mean the switch is out of reach.
struct NativeWriteHealth27 {
    /// How many failed syncs in a row block the native switch.
    static let threshold = 2

    /// Failed syncs since the last one that succeeded.
    private(set) var consecutiveFailures = 0

    /// Whether writes have failed often enough that the native switch is treated as unavailable.
    var isBlocked: Bool {
        consecutiveFailures >= Self.threshold
    }

    /// Records the outcome of a write through the native switch.
    mutating func record(synchronized: Bool) {
        consecutiveFailures = synchronized ? 0 : consecutiveFailures + 1
    }
}
