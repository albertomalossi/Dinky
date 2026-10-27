import CoreGraphics
import Testing
@testable import DinkyLayout

struct TilingAreaTests {
    // A 1728×1117 display with a 33 pt menu bar.
    let frame = rect(0, 0, 1728, 1117)
    // What macOS reports after Mission Control with an auto-hidden Dock: the shown Dock's 67 pt strip.
    let stale = rect(0, 33, 1728, 1017)

    @Test func `A Dock that stays shown keeps its reserved area`() {
        #expect(tilingArea(frame: frame, visible: stale, dockAutohides: false) == stale)
    }

    @Test func `An auto-hidden Dock's stale strip is tiled over`() {
        #expect(tilingArea(frame: frame, visible: stale, dockAutohides: true) == rect(0, 33, 1728, 1084))
    }

    @Test(arguments: [rect(0, 33, 1728, 1017), rect(67, 33, 1661, 1084), rect(0, 33, 1661, 1084)])
    func `A stale Dock strip coming and going leaves the tiling area unchanged`(stale: CGRect) {
        let normal = rect(0, 33, 1728, 1084)
        #expect(tilingArea(frame: frame, visible: normal, dockAutohides: true) == normal)
        #expect(tilingArea(frame: frame, visible: stale, dockAutohides: true) == normal)
        #expect(tilingArea(frame: frame, visible: stale, dockAutohides: false) == stale)
    }

    @Test func `An auto-hidden Dock on the side frees that side`() {
        #expect(tilingArea(frame: frame, visible: rect(4, 33, 1724, 1084), dockAutohides: true) == rect(0, 33, 1728, 1084))
    }

    @Test func `A hidden menu bar frees the top too`() {
        #expect(tilingArea(frame: frame, visible: rect(0, 0, 1728, 1113), dockAutohides: true) == frame)
    }

    @Test func `A display away from the origin keeps its own edges`() {
        let frame = rect(1728, -200, 2560, 1440)
        #expect(tilingArea(frame: frame, visible: rect(1728, -175, 2560, 1345), dockAutohides: true)
                == rect(1728, -175, 2560, 1415))
    }
}
