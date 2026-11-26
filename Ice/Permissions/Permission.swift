//
//  Permission.swift
//  Ice
//

import Combine
import Cocoa

// MARK: - Permission

/// An object that encapsulates the behavior of checking for and requesting
/// a specific permission for the app.
@MainActor
class Permission: ObservableObject, Identifiable {
    /// A Boolean value that indicates whether the app has this permission.
    @Published private(set) var hasPermission = false

    /// The title of the permission.
    let title: String

    /// Descriptive details for the permission.
    let details: [String]

    /// A Boolean value that indicates if the app can work without this permission.
    let isRequired: Bool

    /// Whether a grant only reads as granted once Ice has restarted (Screen Recording).
    let takesEffectAfterRestart: Bool

    /// Whether the user asked for this permission since Ice started.
    @Published private(set) var wasRequested = false

    /// The URL of the settings pane to open.
    private let settingsURL: URL?

    /// The function that checks permissions.
    private let check: () -> Bool

    /// The function that requests permissions.
    private let request: () -> Void

    /// Observer that runs on a timer to check permissions.
    private var timerCancellable: AnyCancellable?

    /// Observer that observes the ``hasPermission`` property.
    private var hasPermissionCancellable: AnyCancellable?

    /// Creates a permission.
    ///
    /// - Parameters:
    ///   - title: The title of the permission.
    ///   - details: Descriptive details for the permission.
    ///   - isRequired: A Boolean value that indicates if the app can work without this permission.
    ///   - takesEffectAfterRestart: Whether a grant only reads as granted after a restart.
    ///   - settingsURL: The URL of the settings pane to open.
    ///   - check: A function that checks permissions.
    ///   - request: A function that requests permissions.
    init(
        title: String,
        details: [String],
        isRequired: Bool,
        takesEffectAfterRestart: Bool = false,
        settingsURL: URL?,
        check: @escaping () -> Bool,
        request: @escaping () -> Void
    ) {
        self.title = title
        self.details = details
        self.isRequired = isRequired
        self.takesEffectAfterRestart = takesEffectAfterRestart
        self.settingsURL = settingsURL
        self.check = check
        self.request = request
        self.hasPermission = check()
        configureCancellables()
    }

    /// Sets up the internal observers for the permission.
    private func configureCancellables() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .merge(with: Just(.now))
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                hasPermission = check()
            }
    }

    /// Performs the request and opens the System Settings app to the appropriate pane.
    func performRequest() {
        wasRequested = true
        request()
        if let settingsURL {
            NSWorkspace.shared.open(settingsURL)
        }
    }

    /// Asynchronously waits for the app to be granted this permission.
    func waitForPermission() async {
        configureCancellables()
        guard !hasPermission else {
            return
        }
        return await withCheckedContinuation { continuation in
            hasPermissionCancellable = $hasPermission.sink { [weak self] hasPermission in
                guard let self else {
                    continuation.resume()
                    return
                }
                if hasPermission {
                    hasPermissionCancellable?.cancel()
                    continuation.resume()
                }
            }
        }
    }

    /// Stops running the permission check.
    func stopCheck() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hasPermissionCancellable?.cancel()
        hasPermissionCancellable = nil
    }
}

// MARK: - AccessibilityPermission

final class AccessibilityPermission: Permission {
    init() {
        super.init(
            title: "Accessibility",
            details: [
                "Get real-time information about the menu bar.",
                "Arrange menu bar items.",
            ],
            isRequired: true,
            settingsURL: nil,
            check: {
                AXHelpers.isProcessTrusted()
            },
            request: {
                AXHelpers.isProcessTrusted(prompt: true)
            }
        )
    }
}

// MARK: - ScreenRecordingPermission

final class ScreenRecordingPermission: Permission {
    init() {
        super.init(
            title: "Screen Recording",
            details: [
                "Change the menu bar's appearance.",
                "Display images of individual menu bar items.",
            ],
            isRequired: false,
            takesEffectAfterRestart: true,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"),
            check: {
                ScreenCapture.checkPermissions()
            },
            request: {
                ScreenCapture.requestPermissions()
            }
        )
    }
}

// MARK: - FullDiskAccessPermission

/// Full Disk Access, which the native hiding method needs on macOS 27.
///
/// MenuBarAgent keeps its "Allow in the Menu Bar" switches in the `group.com.apple.controlcenter`
/// container, and macOS opens that container to other apps only with Full Disk Access: the
/// narrower consent for another app's data is refused without asking (measured 2026-11-26). The
/// check is the very read the native method needs, so "granted" means native hiding works.
final class FullDiskAccessPermission: Permission {
    /// The Full Disk Access pane of Privacy & Security.
    static let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")

    init() {
        super.init(
            title: "Full Disk Access",
            details: [
                "Hide apps with macOS's own Allow in the Menu Bar switch.",
                "Without it, hidden items briefly show when you click the clock, Wi-Fi or battery.",
                "Ice is not listed there by itself: click +, then choose Ice from Applications.",
            ],
            isRequired: false,
            settingsURL: Self.settingsURL,
            check: {
                if #available(macOS 27.0, *) {
                    return NativeAllowListConcealer27.isAvailable
                }
                return true
            },
            request: {
                // Full Disk Access cannot be requested; the user grants it in System Settings.
            }
        )
    }
}
