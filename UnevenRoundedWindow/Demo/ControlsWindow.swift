//
//  ControlsWindow.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

/// A transparent window behind the main window, with a slider on each side.
final class ControlsWindow: NSWindow {
    static let margin: CGFloat = 88

    init(radii: CornerRadii, onChange: @escaping (CornerRadii) -> ()) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovable = false
        contentView = ControlsView(radii: radii, onChange: onChange)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func layout(around frame: NSRect) {
        setFrame(frame.insetBy(dx: -Self.margin, dy: -Self.margin), display: true)
    }
}

// Each slider sets the corner at the clockwise end of it's side
private final class ControlsView: NSView {
    private enum Corner: CaseIterable {
        case topLeft, topRight, bottomRight, bottomLeft

        var title: String {
            switch self {
            case .topLeft: "Top left"
            case .topRight: "Top right"
            case .bottomRight: "Bottom right"
            case .bottomLeft: "Bottom left"
            }
        }

        var keyPath: WritableKeyPath<CornerRadii, CGFloat> {
            switch self {
            case .topLeft: \.topLeft
            case .topRight: \.topRight
            case .bottomRight: \.bottomRight
            case .bottomLeft: \.bottomLeft
            }
        }
    }

    private var radii: CornerRadii
    private let onChange: (CornerRadii) -> ()
    private var sliders: [Corner: NSSlider] = [:]
    private var labels: [Corner: NSTextField] = [:]

    init(radii: CornerRadii, onChange: @escaping (CornerRadii) -> ()) {
        self.radii = radii
        self.onChange = onChange
        super.init(frame: .zero)

        for corner in Corner.allCases {
            let slider = NSSlider(
                value: radii[keyPath: corner.keyPath],
                minValue: 0,
                maxValue: 80,
                target: self,
                action: #selector(sliderChanged)
            )
            slider.isVertical = corner == .topRight || corner == .bottomLeft
            slider.controlSize = .small
            sliders[corner] = slider
            addSubview(slider)

            let label = NSTextField(labelWithString: "")
            label.font = .monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .medium)
            label.textColor = .secondaryLabelColor
            label.alignment = corner == .bottomRight ? .right : .left
            labels[corner] = label
            addSubview(label)
        }

        updateLabels()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        let margin = ControlsWindow.margin
        let inner = bounds.insetBy(dx: margin, dy: margin)
        let length: CGFloat = 120
        let labelHeight: CGFloat = 30
        let thickness: CGFloat = 20
        let column = margin - 12

        let topY = inner.maxY + (margin - labelHeight - thickness) / 2
        sliders[.topLeft]?.frame = NSRect(x: inner.minX, y: topY, width: length, height: thickness)
        labels[.topLeft]?.frame = NSRect(x: inner.minX, y: topY + thickness, width: length, height: labelHeight)

        let bottomY = (margin - labelHeight - thickness) / 2
        sliders[.bottomRight]?.frame = NSRect(x: inner.maxX - length, y: bottomY + labelHeight, width: length, height: thickness)
        labels[.bottomRight]?.frame = NSRect(x: inner.maxX - length, y: bottomY, width: length, height: labelHeight)

        let rightX = inner.maxX + 6
        labels[.topRight]?.frame = NSRect(x: rightX, y: inner.maxY - labelHeight, width: column, height: labelHeight)
        sliders[.topRight]?.frame = NSRect(x: rightX + (column - thickness) / 2, y: inner.maxY - labelHeight - 4 - length, width: thickness, height: length)

        labels[.bottomLeft]?.frame = NSRect(x: 6, y: inner.minY, width: column, height: labelHeight)
        sliders[.bottomLeft]?.frame = NSRect(x: 6 + (column - thickness) / 2, y: inner.minY + labelHeight + 4, width: thickness, height: length)
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        guard let corner = sliders.first(where: { $0.value === sender })?.key else { return }
        radii[keyPath: corner.keyPath] = sender.doubleValue.rounded()
        updateLabels()
        onChange(radii)
    }

    private func updateLabels() {
        for corner in Corner.allCases {
            labels[corner]?.stringValue = "\(corner.title)\n\(Int(radii[keyPath: corner.keyPath])) pt"
        }
    }
}
