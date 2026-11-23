//
//  CornerRadii.swift
//  UnevenRoundedWindow
//
//  Created by Kai Azim on 2026-11-23.
//

import CoreGraphics

nonisolated struct CornerRadii: Equatable {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    init(all radius: CGFloat) {
        self.init(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
    }
}
