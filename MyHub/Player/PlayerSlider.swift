//
//  PlayerSlider.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit

class PlayerSlider: UISlider {
    private var lastThumbBounds = CGRect.zero

    var thumbClickableOffset = CGPoint(x: 30.0, y: 40.0)

    var verticalSliderOffset: CGFloat = 0.0

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: UIEdgeInsets(top: -20,
                                                           left: -20,
                                                           bottom: -20,
                                                           right: -20))
        return expandedBounds.contains(point)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var thRect = rect
        thRect.origin.x = thRect.minX - verticalSliderOffset
        thRect.size.width = thRect.width + verticalSliderOffset * 2.0
        lastThumbBounds = super.thumbRect(forBounds: bounds, trackRect: thRect, value: value)
        return lastThumbBounds
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return view }
        guard point.x >= 0, point.x < bounds.width else { return view }
        guard point.y >= -thumbClickableOffset.x * 0.5, point.y < lastThumbBounds.height + thumbClickableOffset.y else { return view }
        return self
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: 2))
    }
}

