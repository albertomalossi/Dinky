import CoreGraphics
import Testing
@testable import DinkyLayout

struct FrameRecoveryTests {
    private let target = CGRect(x: 1247, y: 38, width: 1231, height: 1394)

    private func result(_ got: CGRect?, written: Bool = true) -> FrameResult {
        FrameResult(job: FrameJob(pid: 1, id: 1, frame: target), target: target, got: got, written: written)
    }

    @Test func displacedMailAndSlackNeedRecovery() {
        #expect(result(CGRect(x: 1142, y: 97, width: 1231, height: 1343)).needsRecovery)
        #expect(result(CGRect(x: 1142, y: 98, width: 1231, height: 1342)).needsRecovery)
    }

    @Test func matchedUnreadableAndUnwrittenDoNotRetry() {
        #expect(!result(target).needsRecovery)
        #expect(!result(nil).needsRecovery)
        #expect(!result(.zero, written: false).needsRecovery)
    }

    @Test func realMinimumAtRequestedOriginIsPreserved() {
        #expect(!result(CGRect(x: 1247, y: 38, width: 1300, height: 1400)).needsRecovery)
        #expect(result(CGRect(x: 1247, y: 38, width: 1200, height: 1394)).needsRecovery)
    }
}
