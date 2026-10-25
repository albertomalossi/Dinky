import CoreGraphics

/// Animation history, not proof that a frame write succeeded. An unchanged target is corrected
/// directly rather than starting another spring from a delayed window-server frame. Main thread only.
public struct AnimationTargets {
    private var frames: [WindowID: CGRect] = [:]

    public init() {}

    /// Records the requested tile and reports whether it differs from the previous request.
    @discardableResult
    public mutating func update(_ id: WindowID, to frame: CGRect) -> Bool {
        let changed = frames[id] != frame
        frames[id] = frame
        return changed
    }

    /// Window ids are reused; a new window must get its own first animation.
    public mutating func forget(_ id: WindowID) { frames[id] = nil }

    public mutating func reset() { frames = [:] }
}
