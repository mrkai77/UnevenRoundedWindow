//
//  ThemeFrame.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

/// Subclasses a window's theme frame to give it per-corner radii.
@MainActor
enum ThemeFrame {
    private static let prefix = "UnevenRounded"
    private static let radiiSelector = NSSelectorFromString("_getCachedWindowCornerRadii")
    private static let radiusSelector = NSSelectorFromString("_getCachedDefaultWindowCornerRadius")

    private typealias RadiiFunction = @convention(c) (AnyObject, Selector) -> AnyObject?
    private typealias RadiusFunction = @convention(c) (AnyObject, Selector) -> CGFloat

    static func subclass(of frameClass: AnyClass) -> AnyClass {
        // Borderless windows use a frame without these methods, so there's nothing to override
        guard let radiiMethod = class_getInstanceMethod(frameClass, radiiSelector),
              let radiusMethod = class_getInstanceMethod(frameClass, radiusSelector)
        else { return frameClass }

        let name = prefix + NSStringFromClass(frameClass)
        if let existing = NSClassFromString(name) {
            return existing
        }
        guard let subclass = objc_allocateClassPair(frameClass, name, 0) else {
            return frameClass
        }

        let originalRadii = unsafeBitCast(method_getImplementation(radiiMethod), to: RadiiFunction.self)
        let radii: @MainActor @convention(block) (NSView) -> AnyObject? = { frame in
            guard var radii = (frame.window as? UnevenRoundedWindow)?.cornerRadii else {
                return originalRadii(frame, radiiSelector)
            }

            // Like AppKit, square off corners on edges that aren't rounded, such as in full screen
            if !frame.isTopCornerRounded {
                radii.topLeft = 0
                radii.topRight = 0
            }
            if !frame.isBottomCornerRounded {
                radii.bottomLeft = 0
                radii.bottomRight = 0
            }

            return frame.adjustedCornerRadii(radii)
        }
        class_addMethod(subclass, radiiSelector, imp_implementationWithBlock(radii), method_getTypeEncoding(radiiMethod))

        // AppKit still uses a single default radius in places, so report the largest corner
        let originalRadius = unsafeBitCast(method_getImplementation(radiusMethod), to: RadiusFunction.self)
        let radius: @MainActor @convention(block) (NSView) -> CGFloat = { frame in
            guard let radii = (frame.window as? UnevenRoundedWindow)?.cornerRadii else {
                return originalRadius(frame, radiusSelector)
            }
            return max(radii.topLeft, radii.topRight, radii.bottomLeft, radii.bottomRight)
        }
        class_addMethod(subclass, radiusSelector, imp_implementationWithBlock(radius), method_getTypeEncoding(radiusMethod))

        objc_registerClassPair(subclass)
        return subclass
    }

    /// The default radius from AppKit's own theme frame, ignoring the window's radii.
    static func systemCornerRadius(of window: NSWindow) -> CGFloat {
        guard let frame = window.contentView?.superview else { return 0 }

        var frameClass: AnyClass = type(of: frame)
        if NSStringFromClass(frameClass).hasPrefix(prefix), let superclass = class_getSuperclass(frameClass) {
            frameClass = superclass
        }
        guard let method = class_getInstanceMethod(frameClass, radiusSelector) else { return 0 }

        return unsafeBitCast(method_getImplementation(method), to: RadiusFunction.self)(frame, radiusSelector)
    }
}
