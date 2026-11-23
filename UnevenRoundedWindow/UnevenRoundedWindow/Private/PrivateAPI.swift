//
//  PrivateAPI.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

fileprivate nonisolated extension CornerRadii {
    /// Reads an `NSViewCornerRadii`.
    init(_ object: NSObject) {
        func value(_ key: String) -> CGFloat {
            object.value(forKey: key) as? CGFloat ?? 0
        }
        self.init(
            topLeft: value("topLeft"),
            topRight: value("topRight"),
            bottomLeft: value("bottomLeft"),
            bottomRight: value("bottomRight")
        )
    }

    /// Makes an `NSViewCornerRadii`.
    var object: NSObject? {
        guard let type = NSClassFromString("NSViewCornerRadii") as? NSObject.Type else { return nil }
        let object = type.init()
        object.setValue(topLeft, forKey: "topLeft")
        object.setValue(topRight, forKey: "topRight")
        object.setValue(bottomLeft, forKey: "bottomLeft")
        object.setValue(bottomRight, forKey: "bottomRight")
        return object
    }
}

extension NSWindow {
    /// The window's corner radii after macOS has adjusted them for the display.
    var resolvedCornerRadii: CornerRadii? {
        (value(forKey: "_cornerRadii") as? NSObject).map(CornerRadii.init)
    }

    /// Makes AppKit recompute the window's corner radii.
    func invalidateCornerRadii() {
        let selector = NSSelectorFromString("_cornerMaskChanged")
        if responds(to: selector) {
            perform(selector)
        }
    }

    /// The theme frame class AppKit would normally use for a window of this style.
    static func defaultFrameViewClass(forStyleMask styleMask: UInt) -> AnyClass {
        let selector = NSSelectorFromString("frameViewClassForStyleMask:")
        guard let method = class_getClassMethod(NSWindow.self, selector) else { return NSView.self }
        typealias Function = @convention(c) (AnyClass, Selector, UInt) -> AnyClass
        return unsafeBitCast(method_getImplementation(method), to: Function.self)(self, selector, styleMask)
    }
}

// Methods of the window's theme frame (`NSThemeFrame`)
extension NSView {
    /// Enlarges the bottom corners near the display's rounded corners.
    func adjustedCornerRadii(_ radii: CornerRadii) -> AnyObject? {
        let object = radii.object
        let selector = NSSelectorFromString("_adjustedCornerRadii:")
        guard responds(to: selector) else { return object }
        return perform(selector, with: object)?.takeUnretainedValue() ?? object
    }

    var isTopCornerRounded: Bool {
        bool("topCornerRounded")
    }

    var isBottomCornerRounded: Bool {
        bool("bottomCornerRounded")
    }

    private func bool(_ name: String) -> Bool {
        let selector = NSSelectorFromString(name)
        guard responds(to: selector), let implementation = method(for: selector) else { return true }
        typealias Function = @convention(c) (AnyObject, Selector) -> Bool
        return unsafeBitCast(implementation, to: Function.self)(self, selector)
    }
}
