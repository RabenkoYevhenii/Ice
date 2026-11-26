import Foundation
import Testing
@testable import IceMacOS27Core

@Suite("SelfRelaunch27")
struct SelfRelaunch27Tests {
    /// Runs the relaunch helper under a stand-in for Ice that takes 4 s to exit, with a
    /// recorder in place of `open`, and returns how long after the start the recorder ran.
    private func secondsUntilReopen() throws -> Double {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let mark = dir.appendingPathComponent("opened")
        let recorder = dir.appendingPathComponent("recorder.sh")
        try "#!/bin/sh\n/bin/date +%s.%N > \"\(mark.path)\" 2>/dev/null || /usr/bin/perl -MTime::HiRes=time -e 'printf \"%.3f\", time' > \"\(mark.path)\"\n"
            .write(to: recorder, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: recorder.path)
        let args = SelfRelaunch27.arguments(bundlePath: "/Applications/Ice.app", opener: recorder.path)
        // The stand-in parent: starts the helper exactly as Ice does, then exits after 4 s.
        let quoted = args.map { "'" + $0.replacingOccurrences(of: "'", with: "'\\''") + "'" }.joined(separator: " ")
        let parent = Process()
        parent.executableURL = URL(fileURLWithPath: "/bin/sh")
        parent.arguments = ["-c", "/bin/sh \(quoted) & sleep 4; exit 0"]
        let start = Date().timeIntervalSince1970
        try parent.run()
        parent.waitUntilExit()
        // The helper runs on after the parent; wait until the recorder has written a whole stamp.
        for _ in 0..<100 {
            if
                let stamp = try? String(contentsOf: mark, encoding: .utf8),
                let opened = Double(stamp.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                return opened - start
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        Issue.record("the recorder never ran")
        return -1
    }

    @Test("Ice is reopened only after the quitting instance is gone, however long quitting takes")
    func reopensAfterParentExits() throws {
        let seconds = try secondsUntilReopen()
        #expect(seconds >= 4, "reopened \(seconds) s after the start")
    }
}
