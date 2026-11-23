//
//  AppDelegate.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    private var window: UnevenRoundedWindow!
    private var controlsWindow: ControlsWindow!
    private let table = RadiiTable()

    func applicationDidFinishLaunching(_: Notification) {
        window = UnevenRoundedWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 280),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Uneven Rounded Window"
        window.contentView = table
        window.delegate = self

        // Start from the system's radius; the sliders take over from there
        controlsWindow = ControlsWindow(radii: baseRadii) { [weak self] radii in
            self?.window.cornerRadii = radii
            self?.update()
        }

        window.center()
        window.addChildWindow(controlsWindow, ordered: .below)
        controlsWindow.layout(around: window.frame)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
        update()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func windowDidMove(_: Notification) {
        update()
    }

    func windowDidResize(_: Notification) {
        controlsWindow.layout(around: window.frame)
        update()
    }

    private var baseRadii: CornerRadii {
        window.cornerRadii ?? CornerRadii(all: window.systemCornerRadius)
    }

    private func update() {
        table.update(base: baseRadii, actual: window.resolvedCornerRadii)
    }
}
