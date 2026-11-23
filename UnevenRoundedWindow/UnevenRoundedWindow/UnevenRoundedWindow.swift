//
//  UnevenRoundedWindow.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

/// A window with a different radius for each corner.
/// Unlike a fixed radius, these radii are still also enlarged near the corners of a rounded display.
final class UnevenRoundedWindow: NSWindow {
    /// The radius of each corner, or nil to use the system's default radius.
    var cornerRadii: CornerRadii? {
        didSet {
            guard cornerRadii != oldValue else { return }
            // Invalidating makes AppKit ask the theme frame for its radii again (`_getCachedWindowCornerRadii`),
            // which our subclass overrides.
            invalidateCornerRadii()
        }
    }

    /// The radius macOS gives every corner of this window by default.
    var systemCornerRadius: CGFloat {
        ThemeFrame.systemCornerRadius(of: self)
    }

    // AppKit asks the window class which theme frame to use
    @objc(frameViewClassForStyleMask:)
    class func frameViewClass(forStyleMask styleMask: UInt) -> AnyClass {
        ThemeFrame.subclass(of: defaultFrameViewClass(forStyleMask: styleMask))
    }
}
