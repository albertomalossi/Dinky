import CoreGraphics

/// Bounds event-driven corrections without fighting an app that insists on its own frame.
public struct FrameRecovery {
    private var tile: CGRect?
    private var attempts = 0

    public init() {}

    /// Resting includes the caller's grid and minimum-size tolerance. Ineligible events are dinky's own
    /// writes or user drags, and must neither spend nor replenish the correction budget.
    public mutating func shouldReapply(tile: CGRect, resting: Bool, eligible: Bool) -> Bool {
        guard eligible else { return false }
        if self.tile != tile || resting {
            self.tile = tile
            attempts = 0
        }
        guard !resting, attempts < 3 else { return false }
        attempts += 1
        return true
    }
}
