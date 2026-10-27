import CoreGraphics
import Testing
@testable import DinkyLayout

struct FrameRecoveryTests {
    private let tile = CGRect(x: 1247, y: 38, width: 1231, height: 1394)

    @Test func correctsAppChangesButStopsAfterThreeAttempts() {
        var recovery = FrameRecovery()
        for _ in 0..<3 {
            let reapply = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
            #expect(reapply)
        }
        let fourth = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
        #expect(!fourth)
    }

    @Test func landingAndNewTilesReplenishTheBudget() {
        var recovery = FrameRecovery()
        for _ in 0..<3 { _ = recovery.shouldReapply(tile: tile, resting: false, eligible: true) }
        let landed = recovery.shouldReapply(tile: tile, resting: true, eligible: true)
        let afterLanding = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
        #expect(!landed)
        #expect(afterLanding)
        for _ in 0..<2 { _ = recovery.shouldReapply(tile: tile, resting: false, eligible: true) }
        let moved = tile.offsetBy(dx: 100, dy: 0)
        let newTile = recovery.shouldReapply(tile: moved, resting: false, eligible: true)
        #expect(newTile)
    }

    @Test func ownWritesAndUserDragsDoNotSpendOrResetTheBudget() {
        var recovery = FrameRecovery()
        for _ in 0..<5 {
            let ignored = recovery.shouldReapply(tile: tile, resting: false, eligible: false)
            #expect(!ignored)
        }
        for _ in 0..<3 {
            let reapply = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
            #expect(reapply)
        }
        let ownWrite = recovery.shouldReapply(tile: tile, resting: true, eligible: false)
        let exhausted = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
        #expect(!ownWrite)
        #expect(!exhausted)
    }

    @Test func restingAtAGridOrMinimumSizeDoesNotRecover() {
        var recovery = FrameRecovery()
        // The animator supplies resting, including its previous landed frame, not an exact-size rule.
        let resting = recovery.shouldReapply(tile: tile, resting: true, eligible: true)
        let moved = recovery.shouldReapply(tile: tile, resting: false, eligible: true)
        #expect(!resting)
        #expect(moved)
    }
}
