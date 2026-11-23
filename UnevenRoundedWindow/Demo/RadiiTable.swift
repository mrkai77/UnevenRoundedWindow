//
//  RadiiTable.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import AppKit

/// Shows each corner's radius as set and as macOS acutally applies it.
final class RadiiTable: NSView, NSTableViewDataSource, NSTableViewDelegate {
    private let columns: [(id: String, title: String, keyPath: KeyPath<CornerRadii, CGFloat>?)] = [
        ("row", "", nil),
        ("topLeft", "Top left", \.topLeft),
        ("topRight", "Top right", \.topRight),
        ("bottomLeft", "Bottom left", \.bottomLeft),
        ("bottomRight", "Bottom right", \.bottomRight),
    ]

    private let tableView = NSTableView()
    private var base: CornerRadii?
    private var actual: CornerRadii?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        for column in columns {
            let tableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(column.id))
            tableColumn.title = column.title
            tableColumn.headerCell.alignment = .right
            let font = tableColumn.headerCell.font ?? .systemFont(ofSize: NSFont.smallSystemFontSize)
            tableColumn.width = Self.width(of: column.keyPath == nil ? "Actual" : column.title, font: font) + 10
            tableView.addTableColumn(tableColumn)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.style = .plain
        tableView.rowHeight = 22
        tableView.intercellSpacing = NSSize(width: 6, height: 0)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = false
        tableView.selectionHighlightStyle = .none
        tableView.columnAutoresizingStyle = .noColumnAutoresizing

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        let width = tableView.tableColumns.reduce(0) { $0 + $1.width + tableView.intercellSpacing.width }
        let height = (tableView.headerView?.frame.height ?? 28) + 2 * tableView.rowHeight

        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: width),
            scrollView.heightAnchor.constraint(equalToConstant: height),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(base: CornerRadii, actual: CornerRadii?) {
        self.base = base
        self.actual = actual
        tableView.reloadData()
    }

    func numberOfRows(in _: NSTableView) -> Int {
        2
    }

    func tableView(_: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = columns.first(where: { $0.id == tableColumn?.identifier.rawValue }) else { return nil }

        let label = NSTextField(labelWithString: "")
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        label.alignment = .right

        if let keyPath = column.keyPath {
            let radii = row == 0 ? base : actual
            label.stringValue = radii.map { Self.format($0[keyPath: keyPath]) } ?? "-"
            if row == 1, let base, let actual, actual[keyPath: keyPath] != base[keyPath: keyPath] {
                label.textColor = .controlAccentColor
            }
        } else {
            label.stringValue = row == 0 ? "Base" : "Actual"
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.alignment = .left
        }

        return label
    }

    private static func width(of text: String, font: NSFont) -> CGFloat {
        ceil((text as NSString).size(withAttributes: [.font: font]).width)
    }

    private static func format(_ value: CGFloat) -> String {
        value.rounded() == value ? "\(Int(value))" : String(format: "%.1f", value)
    }
}
