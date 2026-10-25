import CoreGraphics
import Testing
@testable import DinkyLayout

struct AnimationTargetsTests {
    private let first = CGRect(x: 8, y: 38, width: 1231, height: 1394)
    private let second = CGRect(x: 1247, y: 38, width: 1231, height: 1394)

    @Test func unchangedTargetDoesNotRestartAfterFailedWrite() {
        var targets = AnimationTargets()
        #expect(targets.update(1, to: first))
        // The animation finished but the app has not adopted its frame. Another pass must snap.
        #expect(!targets.update(1, to: first))
        #expect(!targets.update(1, to: first))
        #expect(targets.update(1, to: second))
        #expect(targets.update(1, to: first))
    }

    @Test func windowsKeepIndependentAnimationHistory() {
        var targets = AnimationTargets()
        #expect(targets.update(1, to: first))
        #expect(targets.update(2, to: first))
        #expect(!targets.update(1, to: first))
        targets.forget(1)
        #expect(targets.update(1, to: first))
        #expect(!targets.update(2, to: first))
    }

    @Test func disablingResetsAnimationHistory() {
        var targets = AnimationTargets()
        #expect(targets.update(1, to: first))
        targets.reset()
        #expect(targets.update(1, to: first))
    }
}
