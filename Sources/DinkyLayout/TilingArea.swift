import CoreGraphics

/// The area to tile in on a display, in CG coordinates (top-left origin): its `visible` area, or when
/// the Dock auto-hides, everything below the menu bar to the display's other edges.
///
/// After Mission Control, macOS can keep reporting the shown Dock's strip for a minute or more even when it
/// auto-hides. Only the top of the visible area is reliable then, so the menu bar is still left free.
public func tilingArea(frame: CGRect, visible: CGRect, dockAutohides: Bool) -> CGRect {
    guard dockAutohides else { return visible }
    return CGRect(x: frame.minX, y: visible.minY, width: frame.width, height: frame.maxY - visible.minY)
}
