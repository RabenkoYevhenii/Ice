//
//  SelfRelaunch27.swift
//  Ice
//

/// The helper that opens Ice again once the running instance has quit.
///
/// A running app cannot open itself again: `open` on a running Ice only brings it forward. So a
/// short-lived shell waits until Ice — its parent — has exited, then opens it. Waiting for the
/// exit rather than a fixed second matters: quitting runs termination handlers that write
/// preferences, and an `open` that lands while Ice is still quitting reaches the dying instance,
/// leaving no Ice at all, which is the failure the restart exists to prevent.
enum SelfRelaunch27 {
    /// Arguments for `/bin/sh` that open `bundlePath` with `opener` once the parent has exited.
    ///
    /// The wait is bounded at 30 s, so a parent that never quits does not leave the helper behind.
    static func arguments(bundlePath: String, opener: String) -> [String] {
        [
            "-c",
            "i=0; while kill -0 \"$PPID\" 2>/dev/null && [ $i -lt 300 ]; do sleep 0.1; i=$((i + 1)); done; "
                + "\"$1\" \"$0\"",
            bundlePath,
            opener,
        ]
    }
}
