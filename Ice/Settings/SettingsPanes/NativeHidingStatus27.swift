//
//  NativeHidingStatus27.swift
//  Ice
//

import SwiftUI

/// Says, under the hiding method setting, when the native switch is chosen but not in force.
///
/// Without Full Disk Access the switch cannot be read and Ice uses assessment mode instead. That
/// fallback used to show nowhere but the log, so a user who had granted everything Ice asked for
/// saw hidden items flash on every click on the clock and no reason why.
@available(macOS 27.0, *)
struct NativeHidingStatus27: View {
    @ObservedObject var concealer: Concealer27

    var body: some View {
        if concealer.nativeUnavailable {
            VStack(alignment: .leading, spacing: 6) {
                Label {
                    Text(
                        "Not in use: native hiding needs Full Disk Access, so assessment mode is used, and "
                            + "clicks on system items briefly show hidden items."
                    )
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                Button("Open Full Disk Access Settings") {
                    if let url = FullDiskAccessPermission.settingsURL {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
